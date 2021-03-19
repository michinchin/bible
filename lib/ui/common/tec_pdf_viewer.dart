import 'dart:async';

import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:native_pdf_renderer/native_pdf_renderer.dart';
import 'package:tec_util/tec_util.dart';
import 'package:http/http.dart' as http;

import 'common.dart';
import 'tec_interactive_viewer.dart';

class TecPdfViewer extends StatelessWidget {
  final String url;
  final String caption;
  final Duration duration;
  final EdgeInsets boundaryMargin;
  final double minScale;
  final double maxScale;

  const TecPdfViewer({
    Key key,
    @required this.url,
    this.caption,
    this.duration = const Duration(milliseconds: 300),
    this.boundaryMargin = const EdgeInsets.all(60),
    this.minScale = 0.1,
    this.maxScale = 4.0,
  })  : assert(url != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).devicePixelRatio;
    return BlocProvider<_TecPdfViewerBloc>(
      create: (context) => _TecPdfViewerBloc(url: url, scale: scale),
      child: BlocBuilder<_TecPdfViewerBloc, _TecPdfViewerData>(
        builder: (context, data) {
          return data.image == null
              ? (data.error == null
                  ? const Center(child: LoadingIndicator())
                  : Center(child: Text(data.error?.toString() ?? 'Error...')))
              : TecInteractiveViewer(
                  child: Image(image: data.image),
                  caption: caption,
                  duration: duration,
                  boundaryMargin: boundaryMargin,
                  minScale: minScale,
                  maxScale: maxScale,
                );
        },
      ),
    );
  }
}

class _TecPdfViewerBloc extends Cubit<_TecPdfViewerData> {
  _TecPdfViewerBloc({String url, double scale = 1.0})
      : super(_TecPdfViewerData(url, scale ?? 1.0, null, null)) {
    updateWith(url: url);
  }

  final _fcc = FuncCallCoordinator();
  var _loadingPdf = false;
  var _isClosed = false;

  Future<void> updateWith({String url}) async {
    final _url = url ?? state.url;
    var _image = state.image;
    var _error = state.error;

    // If the url changed, cancel loading and clear the image and error.
    if (_url != state.url) {
      _loadingPdf = false;
      _image = null;
      _error = null;
    }

    // If currently loading, just return.
    if (_loadingPdf) return;

    // If no image and no error and an url, start the async loading process...
    if (_image == null && _error == null && _url != null && _url.isNotEmpty) {
      _loadingPdf = true;

      final result = await _imageFromPdf(_url);
      _image = result.value;
      _error = result.error;

      _loadingPdf = false;
    }

    if (_loadingPdf || (_image == null && _error == null)) return;

    assert(_image != null || _error != null);
    emit(_TecPdfViewerData(_url, state.scale, _image, _error));
  }

  Future<ErrorOrValue<MemoryImage>> _imageFromPdf(String url) async {
    // Make sure we only handle one call at a time.
    return _fcc.syncCall<ErrorOrValue<MemoryImage>>((fcc, callId) async {
      PdfDocument pdfDoc;
      PdfPage pdfPage;

      MemoryImage image;
      Object error;

      try {
        if (url.startsWith('http')) {
          final response = await http.get(Uri.parse(url));

          // After every `await`, cancel if other calls are waiting.
          if (_isClosed || fcc.hasCallsWaitingAfter(callId)) throw _Cancel();

          pdfDoc = await PdfDocument.openData(response.bodyBytes);
        } else {
          pdfDoc = await PdfDocument.openFile(url);
        }

        // After every `await`, cancel if other calls are waiting.
        if (_isClosed || fcc.hasCallsWaitingAfter(callId)) throw _Cancel();

        if (pdfDoc == null) {
          throw Exception('PdfDocument.openFile("$url") failed.');
        }

        pdfPage = await pdfDoc.getPage(1);

        // After every `await`, cancel if other calls are waiting.
        if (_isClosed || fcc.hasCallsWaitingAfter(callId)) throw _Cancel();

        if (pdfPage == null) {
          throw Exception('pdfDoc.getPage(1) failed.');
        }

        final pdfImage = await pdfPage.render(
          width: (pdfPage.width * state.scale).round(),
          height: (pdfPage.height * state.scale).round(),
          format: PdfPageFormat.PNG,
        );

        // After every `await`, cancel if other calls are waiting.
        if (_isClosed || fcc.hasCallsWaitingAfter(callId)) throw _Cancel();

        if (pdfImage == null || pdfImage.bytes == null || pdfImage.bytes.isEmpty) {
          throw Exception('pdfPage.render failed');
        }

        image = MemoryImage(pdfImage.bytes, scale: state.scale);
      } catch (e) {
        if (e is! _Cancel) {
          error = Exception('Error loading $url: "$e"');
        }
      }

      // Close the page and doc...
      try {
        await pdfPage?.close();
        await pdfDoc?.close();
      } catch (_) {}

      return ErrorOrValue(error, image);
    });
  }

  @override
  Future<void> close() async {
    _isClosed = true; // ignore_for_file: invariant_booleans
    _fcc.dispose();
    await super.close();
  }
}

class _TecPdfViewerData extends Equatable {
  final String url;
  final double scale;
  final MemoryImage image;
  final Object error;

  const _TecPdfViewerData(this.url, this.scale, this.image, this.error);

  @override
  List<Object> get props => [url, scale, image, error];
}

class _Cancel implements Exception {}
