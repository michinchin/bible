import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/view_data/volume_view_data.dart';
import '../common/common.dart';
import '../common/tec_modal_popup.dart';
import '../common/tec_modal_popup_menu.dart';

enum XrefUiOption { flat, cards }
const _xrefUiOption = XrefUiOption.flat;

Future<void> showXrefsPopup({
  @required BuildContext context,
  @required Reference reference,
  @required String text,
  @required List<Xref> xrefs,
  Offset offset,
}) {
  if (xrefs?.isEmpty ?? true) return Future.value();

  final originalContext = context;
  return showTecModalPopup<void>(
    useRootNavigator: true,
    context: context,
    offset: offset,
    builder: (context) {
      final maxWidth = math.min(420.0, MediaQuery.of(context).size.width);
      final title = 'verse ${reference.verse}'; // reference?.titleWithBookChapterVerse();
      var firstCard = true;
      return BlocProvider.value(
        value: originalContext.bloc<ViewDataBloc>(),
        child: TecPopupSheet(
          padding: const EdgeInsets.all(6),
          // bgOpacity: 0.5,
          // bgBlur: 5,
          title: (tec.isNotNullOrEmpty(title))
              ? Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: TecTitleBar(
                    title: tec.isNullOrEmpty(text) ? title : "'$text', $title",
                    style: const TextStyle(fontSize: 18),
                    maxWidth: maxWidth,
                  ),
                )
              : null,
          child: Material(
            color: Colors.transparent,
            child: Container(
              // color: Colors.red,
              constraints: maxWidth == null ? null : BoxConstraints(maxWidth: maxWidth),
              child: Column(children: [
                ...xrefs.map((xref) {
                  final card = _XrefWidget(
                    xref: xref,
                    padding: _xrefUiOption == XrefUiOption.flat
                        ? const EdgeInsets.all(0)
                        : EdgeInsets.only(left: 4, top: firstCard ? 0 : 4, right: 4, bottom: 4),
                  );
                  firstCard = false;
                  return card;
                }),
              ]),
            ),
          ),
        ),
      );
    },
  );
}

extension XrefsPopupExtOnReference on Reference {
  String titleWithBookChapterVerse({bool includeAbbreviation = false}) {
    final bible = VolumesRepository.shared.bibleWithId(volume ?? 9);
    if (bible != null) {
      if (includeAbbreviation) {
        return '${bible.nameOfBook(book)} $chapter:$verse, ${bible.abbreviation}';
      }
      return '${bible.nameOfBook(book)} $chapter:$verse';
    }
    return ' $chapter:$verse';
  }
}

class _XrefWidget extends StatelessWidget {
  final Xref xref;
  final EdgeInsets padding;

  const _XrefWidget({Key key, @required this.xref, this.padding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final scale = textScaleFactorWith(context);
    final volumeId = context.bloc<ViewDataBloc>().state.asChapterViewData.volumeId;
    final bible = VolumesRepository.shared.volumeWithId(volumeId)?.assocBible;

    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkTheme ? Colors.black : Colors.white;
    final txColor = isDarkTheme ? const Color(0xFF999999) : const Color(0xFF333333);
    final txStyle = TextStyle(color: txColor);

    return _Card(
      color: _xrefUiOption == XrefUiOption.flat ? Colors.transparent : bgColor,
      elevation: _xrefUiOption == XrefUiOption.flat ? 0 : 4,
      padding: padding ?? const EdgeInsets.all(4),
      cornerRadius: 8,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: TecText.rich(TextSpan(children: [
          TextSpan(
              text: '${bible.nameOfBook(xref.book)} ${xref.chapter}:${xref.verse}  ',
              style: TextStyle(fontWeight: FontWeight.bold, color: txColor)),
          TextSpan(text: xref.text, style: txStyle),
        ])),
      ),
      onTap: () {
        final viewData = context
            .bloc<ViewDataBloc>()
            .state
            .asChapterViewData
            .copyWith(bcv: BookChapterVerse(xref.book, xref.chapter, xref.verse));
        tec.dmPrint('Xref updating with new data: $viewData');
        context.bloc<ViewDataBloc>().update(viewData);
        Navigator.of(context).maybePop();
      },
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final GestureTapCallback onTap;
  final Color color;
  final double elevation;
  final EdgeInsets padding;
  final double cornerRadius;

  const _Card({
    Key key,
    this.child,
    this.onTap,
    this.color = Colors.white,
    this.elevation = 7,
    this.padding,
    this.cornerRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cornerRadius = this.cornerRadius ?? 16.0;
    return Padding(
      padding: padding ?? EdgeInsets.all(defaultPaddingWith(context)),
      child: Container(
        decoration: boxDecoration(
          color: color,
          cornerRadius: cornerRadius,
          boxShadow: elevation == 0
              ? null
              : boxShadow(
                  color: Colors.black26, offset: Offset(0, elevation - 1), blurRadius: elevation),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(cornerRadius)),
          child: Stack(
            fit: StackFit.passthrough,
            children: <Widget>[
              child,
              if (onTap != null)
                Positioned.fill(
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(splashColor: Colors.grey.withOpacity(0.5), onTap: onTap),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
