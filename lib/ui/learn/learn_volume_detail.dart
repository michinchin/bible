import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_env/tec_env.dart';
import 'package:tec_html/tec_html.dart';
import 'package:tec_util/tec_util.dart';

import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../models/app_settings.dart';
import '../common/common.dart';
import '../library/volume_detail.dart';
import '../library/volume_image.dart';
import '../volume/study/study_res_bloc.dart';
import '../volume/study/study_res_card.dart';
import '../volume/study/study_res_view.dart';

class LearnVolumeDetail extends StatelessWidget {
  final Volume volume;
  final Reference reference;
  final String heroPrefix;

  const LearnVolumeDetail({
    Key key,
    @required this.volume,
    @required this.reference,
    @required this.heroPrefix,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

    final bible = VolumesRepository.shared.volumeWithId(volume.id)?.assocBible();

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
            Text(volume.name),
          ],
        );

    return Scaffold(
      appBar: AppBar(elevation: 1, centerTitle: false, title: title()),
      body: SafeArea(
        child: TecFutureBuilder<ErrorOrValue<List<Resource>>>(
          futureBuilder: () => volume.resourcesWithBook(reference.book, reference.chapter),
          builder: (context, result, error) {
            final finalError = error ?? result?.error;
            final resourceList = result?.value;
            if (resourceList != null) {
              final other = <Resource>[];
              final studyNotes = resourceList.expand<Resource>((el) {
                if (el.hasType(ResourceType.studyNote)) {
                  final studyNoteRef = reference.copyWith(
                    verse: el.verse,
                    word: Reference.minWord,
                    endVerse: el.endVerse,
                    endWord: Reference.maxWord,
                  );
                  if (reference.overlaps(studyNoteRef)) {
                    return [el];
                  }
                } else {
                  other.add(el);
                }
                return [];
              }).toList();

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

              return studyNotes.isEmpty && other.isEmpty
                  ? const Center(child: Text('There are no resources for this reference.'))
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (studyNotes.isNotEmpty) ...[
                            section(
                                'Study Notes for ${bible.nameOfBook(reference.book)} ${reference.chapter}:${reference.versesToString()}'),
                            TecHtml(
                              _htmlFromStudyNotes(studyNotes, volume, context),
                              baseUrl: volume.baseUrl,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              // textStyle: TextStyle(fontSize: 16, color: textColor),
                              backgroundColor: Theme.of(context).backgroundColor,
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
                                  onTap: () => onTap(context, e)))),
                          section('Title Details'),
                          const SizedBox(height: 16),
                          VolumeDetailCard(
                            volume: volume,
                            textScaleFactor: textScaleFactor,
                            padding: padding,
                            // heroPrefix: heroPrefix,
                          ),
                          VolumeDescription(
                            volume: volume,
                            textScaleFactor: textScaleFactor,
                            padding: padding,
                          ),
                        ],
                      ),
                    );
            } else {
              return Center(
                child: finalError == null ? const LoadingIndicator() : Text(finalError.toString()),
              );
            }
          },
        ),
      ),
    );
  }

  void onTap(BuildContext context, Resource res) {
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

String _htmlFromStudyNotes(List<Resource> studyNotes, Volume volume, BuildContext context) {
  final html = StringBuffer();
  for (final note in studyNotes) {
    if (html.isNotEmpty) html.writeln('<p> </p>');
    html.writeln('<div class="v" id="${note.verse}" end="${note.endVerse}">${note.textData}</div>');
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
