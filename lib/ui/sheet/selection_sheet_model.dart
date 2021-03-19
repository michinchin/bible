import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tec_bloc/tec_bloc.dart';
import 'package:tec_util/tec_util.dart';
import 'package:tec_views/tec_views.dart';
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_web_view/tec_web_view.dart';
import 'package:tec_widgets/tec_widgets.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import '../../blocs/prefs_bloc.dart';
import '../../blocs/selection/selection_bloc.dart';
import '../../blocs/sheet/sheet_manager_bloc.dart';
import '../../models/chapter_verses.dart';
import '../../models/color_utils.dart';
import '../../models/pref_item.dart';
import '../../models/reference_ext.dart';
import '../../models/search/tec_share.dart';
import '../common/common.dart';
import '../volume/volume_view_data.dart';
import '../volume/volume_view_data_bloc.dart';
import 'compare_verse.dart';
import 'snap_sheet.dart';

//ignore: avoid_classes_with_only_static_members
class SelectionSheetModel {
  static const buttons = <String, IconData>{
    // 'Explore': FeatherIcons.compass,
    'Compare': Icons.compare_arrows,
    // 'Define': FeatherIcons.bookOpen,
    'Note': FeatherIcons.edit,
    'Learn': Icons.lightbulb_outline
    // 'Copy': FeatherIcons.copy,
    // 'Note': FeatherIcons.edit2,
    // 'Audio': FeatherIcons.play,
    // 'Save': FeatherIcons.bookmark,
    // 'Print': FeatherIcons.printer,
    // 'Text': FeatherIcons.messageCircle,
    // 'Email': FeatherIcons.mail,
    // 'Facebook': FeatherIcons.facebook,
    // 'Twitter': FeatherIcons.twitter
  };

  static const miniButtons = <String, IconData>{
    // 'No Color': Icons.format_color_reset,
    'Save': FeatherIcons.bookmark,
    'Copy': FeatherIcons.copy,
    'Share': FeatherIcons.share,
    'Compare': Icons.compare_arrows,
    'Learn': Icons.lightbulb_outline,
    // 'Audio': Icons.play_arrow,
    'Note': FeatherIcons.edit2,
  };

  static const buttonSubtitles = <String, String>{
    'Web Search': 'Search the web for more insight on scriptures',
    'Define': 'Find word definitions on google',
    'Compare': 'View other translations',
    'Note': 'Make margin note',
    'Learn': 'View helpful study materials'
  };

  static final defaultColors = <Color>[
    Color(defaultColorIntForIndex(1)),
    Color(defaultColorIntForIndex(2)),
    Color(defaultColorIntForIndex(3)),
    Color(defaultColorIntForIndex(4)),
  ];

  static Widget underlineButton(
          {@required bool underlineMode, @required VoidCallback onSwitchToUnderline}) =>
      SelectionSheetButton(
        icon: underlineMode ? FeatherIcons.edit3 : FeatherIcons.underline,
        onPressed: onSwitchToUnderline,
      );

  static Widget noColorButton(BuildContext context,
      {bool forUnderline = false, double radius = 20}) {
    final borderColor = Theme.of(context).appBarTheme.textTheme.headline6.color;
    return forUnderline
        ? InkWell(
            customBorder: const CircleBorder(),
            onTap: () => _noColor(context),
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Container(
                height: 15,
                width: radius * 2,
                decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(
                          width: 2,
                          color: borderColor,
                        ))),
                child: Transform.rotate(
                    angle: 10,
                    child: VerticalDivider(
                      color: borderColor,
                      thickness: 2,
                    )),
              ),
            ),
          )
        : SizedBox.fromSize(
            size: Size.fromRadius(radius),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => _noColor(context),
              child: Container(
                decoration: ShapeDecoration(
                    shape: CircleBorder(side: BorderSide(color: borderColor, width: 2))),
                child: Transform.rotate(
                    angle: 10,
                    child: VerticalDivider(
                      color: borderColor,
                      thickness: 2,
                    )),
              ),
            ),
          );
  }

  static Widget pickColorButton({@required bool editMode, @required VoidCallback onEditMode}) =>
      SelectionSheetButton(
        icon: editMode ? Icons.close : Icons.colorize_outlined,
        onPressed: onEditMode,
      );

  static Future<void> defineWebSearch(BuildContext c) async {
    final refs = _grabRefs(c);

    if (refs.length > 1) {
      final refChosen = await _showRefPickerDialog(c, refs, title: 'Select Verse to Web Search');
      if (refChosen != null) {
        await _defineWebSearch(c, refChosen);
      }
    } else if (refs.isNotEmpty) {
      final ref = refs[0];
      await _defineWebSearch(c, ref);
    }
  }

  static void buttonAction(BuildContext context, String type) {
    switch (type) {
      case 'Define':
        // _defineWebSearch(context);
        break;
      case 'Compare':
        _compare(context);
        break;
      case 'No Color':
        _noColor(context);
        break;
      case 'Deselect':
        deselect(context);
        break;
      case 'Copy':
        copy(context);
        break;
      case 'Share':
        share(context);
        break;
      case 'Learn':
        // put define/web search in learn for now
        defineWebSearch(context);
        break;
      default:
        break;
    }
  }

  static void _noColor(BuildContext context) =>
      context.tbloc<SelectionCmdBloc>()?.add(const SelectionCmd.clearStyle());

  static void deselect(BuildContext c) =>
      c.tbloc<SelectionCmdBloc>()?.add(const SelectionCmd.deselectAll());

  static Future<void> copy(BuildContext c, {int uid}) async {
    TecShare.copy(c, await _shareText(c, uid: uid, maybeAddLink: false));

    // never include link with copy
    // final shareWithLink = c.tbloc<PrefItemsBloc>().itemBool(PrefItemId.includeShareLink);
    // if (shareWithLink) {
    //   final text = await tecShowProgressDlg<String>(
    //     context: c,
    //     title: 'Copying to clipboard...',
    //     future: _shareText(c, uid: uid, maybeAddLink: true),
    //   );
    //   TecShare.copy(c, text.value);
    // } else {
    //   TecShare.copy(c, await _shareText(c, uid: uid, maybeAddLink: false));
    // }

    if (PrefsBloc.getBool(PrefItemId.closeAfterCopyShare)) {
      deselect(c);
    }
  }

  static Future<String> _shareText(BuildContext c, {int uid, bool maybeAddLink = true}) async {
    final bloc = c.viewManager; //ignore: close_sinks
    final views = bloc.visibleViewsWithSelections.toList();
    final buffer = StringBuffer('');

    Future<void> writeRef(Reference ref, int bibleId) async {
      // final key = '${ref.book} ${ref.chapter}';

      final v = await VolumesRepository.shared.bibleWithId(bibleId).referenceAndVerseTextWith(ref);
      final verses = v.value.verseText;
      final shareWithLink = PrefsBloc.getBool(PrefItemId.includeShareLink);
      final verse = ChapterVerses.formatForShare([v.value.reference], verses);
      buffer.write(verse);
      if (maybeAddLink && shareWithLink) {
        buffer.write(await TecShare.shareLink(ref));
      }
    }

    if (uid != null) {
      final ref = as<Reference>(bloc.selectionObjectWithViewUid(uid));
      final bible = VolumeViewData.fromContext(c, uid)?.volumeId;
      await writeRef(ref, bible);
    } else {
      for (final vuid in views) {
        final ref = as<Reference>(bloc.selectionObjectWithViewUid(vuid));
        final bible = VolumeViewData.fromContext(c, vuid)?.volumeId;
        await writeRef(ref, bible);
        if (vuid != views.last) {
          buffer.writeln('\n');
        }
      }
    }

    dmPrint('SHARE TEXT: ${buffer.toString()}');
    return buffer.toString();
  }

  static Future<void> share(BuildContext c, {int uid}) async {
    final copyWithLink = PrefsBloc.getBool(PrefItemId.includeShareLink);
    if (copyWithLink) {
      final text = await tecShowProgressDlg<String>(
        context: c,
        title: 'Preparing to share...',
        future: _shareText(c, uid: uid),
      );
      TecShare.share(text.value);
    } else {
      TecShare.share(await _shareText(c, uid: uid, maybeAddLink: false));
    }

    if (PrefsBloc.getBool(PrefItemId.closeAfterCopyShare)) {
      deselect(c);
    }
  }

  static Future<void> _defineWebSearch(BuildContext c, Reference ref) async {
    final value = await tecShowProgressDlg<ChapterVerses>(
        context: c, future: ChapterVerses.fetch(refForChapter: ref));
    ChapterVerses verses;
    if (value.error == null) {
      verses = value.value;
    }
    var words = '';
    final verseArray = verses.data[ref.verse].split(' ');
    if (ref.word != 0 && ref.endWord != 9999) {
      if (ref.word == ref.endWord) {
        words = verseArray[ref.word - 1];
      } else if (verseArray.length > ref.word - 1 && verseArray.length > ref.endWord) {
        words = verseArray.getRange(ref.word - 1, ref.endWord).join(' ');
      }
    } else {
      final reference = ref.label().split(' ').take(2);
      words = reference.join(' ');
    }

    await showModalBottomSheet<void>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      context: c,
      useRootNavigator: true,
      isScrollControlled: true,
      enableDrag: false,
      builder: (c) => SizedBox(
        height: 3 * MediaQuery.of(c).size.height / 4,
        child: _DefineWebView(words),
      ),
    );
  }

  static Future<void> _compare(BuildContext c) async {
    final bloc = c.viewManager; //ignore: close_sinks
    final views = bloc.visibleViewsWithSelections.toList();
    final refs = <Reference>[];
    for (final v in views) {
      refs.add(as<Reference>(bloc.selectionObjectWithViewUid(v)));
    }
    var ref = refs[0];
    // ask for which verse to compare if multiple selected in views
    if (refs.length > 1) {
      final refChosen = await _showRefPickerDialog(c, refs, title: 'Select Verse to Compare');
      if (refChosen != null) {
        ref = refChosen;
      } else {
        return;
      }
    }
    final bibleId = await showCompareSheet(c, ref);
    if (bibleId != null) {
      final bloc = c.viewManager.dataBlocWithView(views.first) as VolumeViewDataBloc;
      final viewData = bloc.state.asVolumeViewData.copyWith(volumeId: bibleId);
      await bloc.update(c, viewData);
      c.tbloc<SelectionCmdBloc>().add(const SelectionCmd.deselectAll());
      c.tbloc<SheetManagerBloc>().add(SheetEvent.main);
    }
  }

  static Future<Reference> _showRefPickerDialog(BuildContext c, List<Reference> refs,
          {String title = 'Select Verse'}) =>
      showTecDialog<Reference>(
          context: c,
          builder: (c) => Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title),
                    for (final ref in refs)
                      ListTile(title: Text(ref.label()), onTap: () => Navigator.of(c).pop(ref))
                  ],
                ),
              ));

  static List<Reference> _grabRefs(BuildContext c) {
    final bloc = c.viewManager; //ignore: close_sinks
    final views = bloc.visibleViewsWithSelections.toList();
    final refs = <Reference>[];
    for (final v in views) {
      refs.add(as<Reference>(bloc.selectionObjectWithViewUid(v)));
    }
    return refs;
  }
}

class _DefineWebView extends StatefulWidget {
  final String words;

  const _DefineWebView(this.words);

  @override
  __DefineWebViewState createState() => __DefineWebViewState();
}

class __DefineWebViewState extends State<_DefineWebView> {
  String url;

  @override
  void initState() {
    url = Uri.https('google.com', '/search', <String, String>{'q': 'define:${widget.words}'})
        .toString();
    super.initState();
  }

  void onWebCreated(WebController webController) {
    webController..loadUrl(url);
  }

  Future<void> _launchSearch() async {
    try {
      if (await launcher.canLaunch(url)) {
        await launcher.launch(url, forceSafariVC: false, forceWebView: false);
      }
    } catch (e) {
      final msg = 'Error launching web search: ${e.toString()}';
      await Navigator.of(context).maybePop();
      TecToast.show(context, msg);
      dmPrint(msg);
    }
    await Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const CloseButton(),
        automaticallyImplyLeading: false,
        actions: [IconButton(icon: const Icon(FeatherIcons.compass), onPressed: _launchSearch)],
      ),
      body: SafeArea(
        child: TecWebView(
          onWebCreated: onWebCreated,
          backgroundColor: Theme.of(context).canvasColor,
          loadingIndicator: const LoadingIndicator(),
        ),
      ),
    );
  }
}
