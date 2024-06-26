import 'package:flutter/material.dart';

import 'package:collection/collection.dart' as collection;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_env/tec_env.dart';
import 'package:tec_html/tec_html.dart';
import 'package:tec_util/tec_util.dart';
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../models/app_settings.dart';
import '../common/common.dart';
import '../library/volume_detail.dart';
// import '../library/volume_image.dart';
import '../volume/study/study_res_bloc.dart';
import '../volume/study/study_res_card.dart';
import '../volume/study/study_res_view.dart';
import 'learn.dart';

class LearnVolumeDetail extends StatefulWidget {
  final Volume volume;
  final Reference reference;
  final bool showOnlyStudyNotes;

  const LearnVolumeDetail({
    Key key,
    @required this.volume,
    @required this.reference,
    this.showOnlyStudyNotes = false,
  }) : super(key: key);

  @override
  _LearnVolumeDetailState createState() => _LearnVolumeDetailState();
}

class _LearnVolumeDetailState extends State<LearnVolumeDetail> {
  bool _showOnlyFirstStudyNote = true;

  @override
  void initState() {
    super.initState();
    _showOnlyFirstStudyNote = !widget.showOnlyStudyNotes;
  }

  @override
  Widget build(BuildContext context) {
    final bible = VolumesRepository.shared.volumeWithId(widget.volume.id)?.assocBible();

    /*
    Widget image() => TecCard(
          color: Colors.transparent,
          padding: 0,
          elevation: defaultElevation,
          cornerRadius: 8,
          builder: (context) => VolumeImage(volume: volume),
        );

    Widget title() => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 50,
              child: isNotNullOrEmpty(heroPrefix)
                  ? Hero(
                      tag: heroTagForVolume(volume, heroPrefix),
                      child: image(),
                    )
                  : image(),
            ),
            const SizedBox(width: 8),
            Text(volume.name, softWrap: true),
          ],
        );
    */

    final showBackButton = (ModalRoute.of(context)?.canPop ?? false);

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        leading: showBackButton
            ? const BackButton()
            : CloseButton(
                onPressed: () => Navigator.of(context, rootNavigator: true).maybePop(context)),
        centerTitle: false,
        title: Text(widget.volume.name), // title(),
        actions: [
          if (!showBackButton)
            IconButton(
                onPressed: () => Navigator.of(context).pushReplacement<void, void>(
                    MaterialPageRoute(
                        builder: (context) => LearnScaffold(refs: [widget.reference]))),
                icon: const Icon(Icons.lightbulb_outline)),
        ],
      ),
      body: SafeArea(
        child: TecFutureBuilder<ErrorOrValue<List<Resource>>>(
          futureBuilder: () =>
              widget.volume.resourcesWithBook(widget.reference.book, widget.reference.chapter),
          builder: (context, result, error) {
            final finalError = error ?? result?.error;
            final resourceList = result?.value;
            if (resourceList == null) {
              return Center(
                child: finalError == null ? const LoadingIndicator() : Text(finalError.toString()),
              );
            } else {
              // Resource types to not show in list:
              const typesToIgnore = {ResourceType.reference};

              var chapterHasOtherStudyNotes = false;
              final other = <Resource>[];
              final studyNotes = resourceList.expand<Resource>((el) {
                if (el.hasType(ResourceType.studyNote)) {
                  final studyNoteRef = Reference(
                    book: el.book,
                    chapter: el.chapter,
                    verse: el.verse,
                    endVerse:
                        el.endVerse != null && el.endVerse > el.verse ? el.endVerse : el.verse,
                  );
                  if (!_showOnlyFirstStudyNote || widget.reference.overlaps(studyNoteRef)) {
                    return [el];
                  } else {
                    chapterHasOtherStudyNotes = true;
                  }
                } else if (!widget.showOnlyStudyNotes && !el.hasAnyOfTypes(typesToIgnore)) {
                  other.add(el);
                }
                return [];
              }).toList();

              // Sort study notes by number of verses covered, least to greatest.
              if (_showOnlyFirstStudyNote) {
                collection.mergeSort<Resource>(studyNotes,
                    compare: (a, b) => (a.endVerse - a.verse).compareTo(b.endVerse - b.verse));
              }

              final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
              // final textColor = isDarkTheme ? Colors.white : Colors.black;

              Widget section(String title) => Container(
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(minWidth: double.infinity),
                    color: isDarkTheme ? const Color(0xff777777) : const Color(0xffaaaaaa),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDarkTheme ? Colors.black : Colors.white,
                      ),
                    ),
                  );

              // We're deliberately using `scaleFactorWith` instead of `textScaleFactor...` because
              // if the user has their device text scaling set very high, it can cause overflow
              // the the name and publisher text.
              final textScaleFactor = scaleFactorWith(
                context,
                dampingFactor: 0.5,
                minScaleFactor: 1,
                maxScaleFactor: 3,
              );
              final padding = (16.0 * textScaleFactor).roundToDouble();

              return studyNotes.isEmpty && other.isEmpty
                  ? const Center(child: Text('There are no resources for this reference.'))
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (studyNotes.isNotEmpty) ...[
                            section(
                                'Notes for ${bible.nameOfBook(widget.reference.book)} ${widget.reference.chapter}${widget.showOnlyStudyNotes ? '' : ':${widget.reference.versesToString()}'}'),
                            TecHtml(
                              _htmlFromStudyNotes(
                                studyNotes,
                                widget.volume,
                                context,
                                showOnlyFirstStudyNote: _showOnlyFirstStudyNote,
                              ),
                              baseUrl: widget.volume.baseUrl,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              backgroundColor: Theme.of(context).backgroundColor,
                            ),
                            if (_showOnlyFirstStudyNote &&
                                (chapterHasOtherStudyNotes || studyNotes.length > 1))
                              Container(
                                color: isDarkTheme ? Colors.black : Colors.white,
                                child: Center(
                                  child: TextButton(
                                    style: TextButton.styleFrom(),
                                    child: Text('Show all notes for '
                                        '${bible.nameOfBook(widget.reference.book)} '
                                        '${widget.reference.chapter}'),
                                    // onPressed: () =>
                                    //     setState(() => _showOnlyFirstStudyNote = false),
                                    onPressed: () => Navigator.of(context).push<void>(
                                      MaterialPageRoute(
                                        builder: (context) => LearnVolumeDetail(
                                            volume: widget.volume,
                                            reference: widget.reference,
                                            showOnlyStudyNotes: true),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                          if (other.isNotEmpty)
                            section(
                                '${studyNotes.isNotEmpty ? 'Additional ' : ''}Chapter Resources'),
                          ...other.map((e) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              color: isDarkTheme ? Colors.black : Colors.white,
                              child: StudyResCard(
                                  res: e,
                                  parent: null,
                                  bible: bible,
                                  useThumbnail: false,
                                  iconSize: 30,
                                  onTap: () => onTapResCard(context, e)))),
                          if (!widget.showOnlyStudyNotes) ...[
                            section('Title Details'),
                            const SizedBox(height: 16),
                            VolumeDetailCard(
                              volume: widget.volume,
                              textScaleFactor: textScaleFactor,
                              padding: padding,
                              // heroPrefix: heroPrefix,
                            ),
                            VolumeDescription(
                              volume: widget.volume,
                              textScaleFactor: textScaleFactor,
                              padding: padding,
                            ),
                          ],
                        ],
                      ),
                    );
            }
          },
        ),
      ),
    );
  }

  void onTapResCard(BuildContext context, Resource res) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(elevation: 1),
            body: BlocProvider<StudyResBloc>(
              create: (context) => StudyResBloc.withResource(res),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return StudyResView(
                    viewSize: constraints.biggest,
                    padding: EdgeInsets.zero,
                    useAltTopPadding: false,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

String _htmlFromStudyNotes(
  List<Resource> studyNotes,
  Volume volume,
  BuildContext context, {
  bool showOnlyFirstStudyNote = true,
}) {
  final html = StringBuffer();
  for (final note in studyNotes) {
    if (html.isNotEmpty) html.writeln('<br>');
    html.writeln('<div class="v" id="${note.verse}" end="${note.endVerse}">${note.textData}</div>');
    if (showOnlyFirstStudyNote) break;
  }
  if (html.isEmpty) {
    html.writeln('<p>Study notes are not available for this chapter.</p>');
  }

  return TecEnv(darkMode: Theme.of(context).brightness == Brightness.dark)
      .html(
        htmlFragment: html.toString(),
        fontSizePercent: (contentTextScaleFactorWith(context) * 100.0).round(),
        marginLeft: '0px',
        marginRight: '0px',
        marginTop: '0px',
        marginBottom: '0px',
        vendorFolder: volume.vendorFolder,
        customStyles: ' p { line-height: 1.2em; } ',
      )
      .replaceAll('bible_vendor.css', 'studynotes.css');
}
