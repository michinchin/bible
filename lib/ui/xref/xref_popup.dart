import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/view_data/volume_view_data.dart';
import '../common/tec_modal_popup.dart';

Future<void> showXrefsPopup({
  @required BuildContext context,
  @required List<Xref> xrefs,
  EdgeInsetsGeometry insets,
  // double maxWidth = 320,
}) {
  if (xrefs?.isEmpty ?? true) return Future.value();

  final maxWidth = math.min(420.0, (MediaQuery.of(context).size.width * 0.90).roundToDouble());

  final originalContext = context;
  return showTecModalPopup<void>(
    useRootNavigator: true,
    context: context,
    alignment: Alignment.center,
    edgeInsets: insets,
    builder: (context) => BlocProvider.value(
      value: originalContext.bloc<ViewDataBloc>(),
      child: TecPopupSheet(
        padding: const EdgeInsets.all(8),
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: maxWidth == null ? null : BoxConstraints(maxWidth: maxWidth),
            child: Column(
              children: [
                ...xrefs.map((xref) => _XrefWidget(xref: xref)),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _XrefWidget extends StatelessWidget {
  final Xref xref;

  const _XrefWidget({Key key, @required this.xref}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final volumeId = context.bloc<ViewDataBloc>().state.asChapterViewData.volumeId;
    final bible = VolumesRepository.shared.volumeWithId(volumeId)?.assocBible;

    return TecCard(
      elevation: 5,
      padding: 4,
      cornerRadius: 8,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(8),
          child: Text.rich(TextSpan(children: [
            TextSpan(
                text: '${bible.nameOfBook(xref.book)} ${xref.chapter}:${xref.verse}  ',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: xref.text),
          ])),
        );
      },
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
