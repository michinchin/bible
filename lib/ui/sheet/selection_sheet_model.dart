import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_web_view/tec_web_view.dart';
import 'package:tec_widgets/tec_widgets.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import '../../blocs/selection/selection_bloc.dart';
import '../../blocs/sheet/pref_items_bloc.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../../models/chapter_verses.dart';
import '../../models/color_utils.dart';
import '../../models/pref_item.dart';
import '../../models/search/tec_share.dart';
import '../../models/shared_types.dart';
import '../common/common.dart';
import 'compare_verse.dart';
import 'snap_sheet.dart';

//ignore: avoid_classes_with_only_static_members
class SelectionSheetModel {
  static const buttons = <String, IconData>{
    'Learn': Icons.lightbulb_outline,
    'Explore': FeatherIcons.compass,
    'Compare': Icons.compare_arrows,
    'Define': FeatherIcons.bookOpen,
    // 'Copy': FeatherIcons.copy,
    // 'Note': FeatherIcons.edit2,
    'Audio': FeatherIcons.play,
    'Save': FeatherIcons.bookmark,
    'Print': FeatherIcons.printer,
    'Text': FeatherIcons.messageCircle,
    'Email': FeatherIcons.mail,
    'Facebook': FeatherIcons.facebook,
    'Twitter': FeatherIcons.twitter
  };

  static const medButtons = <String, IconData>{
    'Compare': Icons.compare_arrows,
    'Define': FeatherIcons.bookOpen,
  };

  static const keyButtons = <String, IconData>{
    'Note': FeatherIcons.edit,
    'Share': FeatherIcons.share,
    // 'Learn': Icons.lightbulb_outline,
    // 'Compare': FeatherIcons.compass
  };

  static final defaultColors = <Color>[
    Color(defaultColorIntForIndex(1)),
    Color(defaultColorIntForIndex(2)),
    Color(defaultColorIntForIndex(3)),
    Color(defaultColorIntForIndex(4)),
  ];

  static Widget underlineButton(
          {@required bool underlineMode, @required VoidCallback onSwitchToUnderline}) =>
      GreyCircleButton(
        icon: underlineMode ? FeatherIcons.edit3 : FeatherIcons.underline,
        onPressed: onSwitchToUnderline,
      );

  static Widget noColorButton(BuildContext context) => GreyCircleButton(
        icon: Icons.format_color_reset,
        onPressed: () => context.bloc<SelectionStyleBloc>()?.add(const SelectionStyle(
              type: HighlightType.clear,
            )),
      );

  static Widget deselectButton(BuildContext context) => GreyCircleButton(
      icon: Icons.clear,
      onPressed: () => context
          .bloc<SelectionStyleBloc>()
          ?.add(const SelectionStyle(type: HighlightType.clear, isTrialMode: true)));

  static Widget defineButton(BuildContext c) {
    final refs = _grabRefs(c);
    VoidCallback onPressed;
    var title = 'Web Search';
    var icon = FeatherIcons.compass;
    if (refs.length > 1) {
      onPressed = () => TecToast.show(c, 'Cannot search on multiple references');
    } else {
      onPressed = () => defineWebSearch(c);
      if (refs.isNotEmpty) {
        final ref = refs[0];
        if (ref.word == ref.endWord) {
          //single word define
          title = 'Define';
          icon = FeatherIcons.bookOpen;
        }
      }
    }
    return SheetButton(text: title, icon: icon, onPressed: onPressed);
  }

  static void buttonAction(BuildContext context, String type) {
    switch (type) {
      case 'Share':
        share(context);
        break;
      case 'Define':
        defineWebSearch(context);
        break;
      case 'Compare':
        compare(context);
        break;
      default:
        break;
    }
  }

  static Future<void> share(BuildContext c) async {
    final bloc = c.bloc<ViewManagerBloc>(); //ignore: close_sinks
    final views = bloc.visibleViewsWithSelections.toList();
    final refs = <Reference>[];
    for (final v in views) {
      refs.add(tec.as<Reference>(bloc.selectionObjectWithViewUid(v)));
    }
    final ref = refs[0];
    final verses = await ChapterVerses.fetch(refForChapter: ref);
    final shareWithLink = c.bloc<PrefItemsBloc>().itemBool(PrefItemId.includeShareLink);
    final verse = ChapterVerses.formatForShare(refs, verses.data);
    if (shareWithLink) {
      await tecShowProgressDlg<void>(
          context: c, title: 'Preparing to share...', future: TecShare.shareWithLink(verse, ref));
    } else {
      TecShare.share(verse);
    }
  }

  static Future<void> defineWebSearch(BuildContext c) async {
    final ref = _grabRefs(c).first;

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
      words = ref.label();
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

  static Future<void> compare(BuildContext c) async {
    final bloc = c.bloc<ViewManagerBloc>(); //ignore: close_sinks
    final views = bloc.visibleViewsWithSelections.toList();
    final refs = <Reference>[];
    for (final v in views) {
      refs.add(tec.as<Reference>(bloc.selectionObjectWithViewUid(v)));
    }
    final ref = refs[0];
    final bibleId = await showCompareSheet(c, ref);
    if (bibleId != null) {
      // TODO(abby): change chapter view ref to this translation
    }
  }

  static List<Reference> _grabRefs(BuildContext c) {
    final bloc = c.bloc<ViewManagerBloc>(); //ignore: close_sinks
    final views = bloc.visibleViewsWithSelections.toList();
    final refs = <Reference>[];
    for (final v in views) {
      refs.add(tec.as<Reference>(bloc.selectionObjectWithViewUid(v)));
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
    url = Uri.https('google.com', '/search', {'q': 'define:${widget.words}'}).toString();
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
      tec.dmPrint(msg);
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
