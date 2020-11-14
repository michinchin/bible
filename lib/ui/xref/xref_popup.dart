import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../bible/chapter_view_data.dart';
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
      final padding = (6.0 * textScaleFactorWith(context)).roundToDouble();
      final dblPad = padding * 2;
      // final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
      // final titleBgClr =
      //     isDarkTheme ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);
      final title = 'verse ${reference.verse}';
      var firstCard = true;
      return BlocProvider.value(
        value: originalContext.tbloc<ChapterViewDataBloc>(),
        child: TecPopupSheet(
          padding: EdgeInsets.zero,
          title: (tec.isNotNullOrEmpty(title))
              ? Container(
                  // color: _xrefUiOption == XrefUiOption.flat ? titleBgClr : Colors.transparent,
                  constraints: maxWidth == null ? null : BoxConstraints(maxWidth: maxWidth),
                  padding: EdgeInsets.all(padding),
                  child: TecTitleBar(
                    title: tec.isNullOrEmpty(text) ? title : "'$text', $title",
                    style: const TextStyle(fontSize: 18),
                  ),
                )
              : null,
          child: Material(
            color: _xrefUiOption == XrefUiOption.flat ? null : Colors.transparent,
            child: Container(
              constraints: maxWidth == null ? null : BoxConstraints(maxWidth: maxWidth),
              child: Column(children: [
                ...xrefs.expand((xref) {
                  final card = _XrefWidget(
                    xref: xref,
                    padding: EdgeInsets.all(_xrefUiOption == XrefUiOption.flat ? dblPad : padding),
                  );
                  final widgets = firstCard || _xrefUiOption == XrefUiOption.cards
                      ? [card]
                      : [
                          Divider(
                              thickness: 1,
                              height: _xrefUiOption == XrefUiOption.flat ? 1 : dblPad,
                              indent: dblPad,
                              endIndent: dblPad),
                          card
                        ];
                  firstCard = false;
                  return widgets;
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
    final volumeId = context.tbloc<ChapterViewDataBloc>().state.asChapterViewData.volumeId;
    final bible = VolumesRepository.shared.volumeWithId(volumeId)?.assocBible();

    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkTheme ? Colors.black : Colors.white;
    final txColor = isDarkTheme ? const Color(0xFF999999) : const Color(0xFF333333);
    final txStyle = TextStyle(color: txColor);

    return _Card(
      color: _xrefUiOption == XrefUiOption.flat ? Colors.transparent : bgColor,
      elevation: _xrefUiOption == XrefUiOption.flat ? 0 : 3,
      padding: _xrefUiOption == XrefUiOption.flat
          ? EdgeInsets.zero
          : const EdgeInsets.only(left: 8, top: 2, right: 8, bottom: 8),
      cornerRadius: 8,
      child: Container(
        padding: padding ?? const EdgeInsets.all(8),
        child: TecText.rich(TextSpan(children: [
          TextSpan(
              text: '${bible.nameOfBook(xref.book)} ${xref.chapter}:${xref.verse}  ',
              style: TextStyle(fontWeight: FontWeight.bold, color: txColor)),
          TextSpan(text: xref.text, style: txStyle),
        ])),
      ),
      onTap: () {
        final viewData = context
            .tbloc<ChapterViewDataBloc>()
            .state
            .asChapterViewData
            .copyWith(bcv: BookChapterVerse(xref.book, xref.chapter, xref.verse));
        // tec.dmPrint('Xref updating with new data: $viewData');
        context.tbloc<ChapterViewDataBloc>().update(context, viewData);
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
                    child: InkWell(
                      highlightColor: Colors.grey.withOpacity(0.1),
                      splashColor: Colors.grey.withOpacity(0.2),
                      onTap: onTap,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
