import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart';
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../../models/reference_ext.dart';
import '../../common/common.dart';

const TextStyle _titleStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
);

const TextStyle _subtitleStyle = TextStyle(
  fontSize: 15,
);

class StudyResCard extends StatelessWidget {
  final Resource res;
  final Resource parent;
  final Bible bible;
  final VoidCallback onTap;
  final double iconSize;
  final bool useThumbnail;

  const StudyResCard({
    Key key,
    @required this.res,
    @required this.parent,
    @required this.bible,
    @required this.onTap,
    this.useThumbnail = true,
    this.iconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = useThumbnail
        ? VolumesRepository.shared.volumeWithId(res.volumeId)?.thumbnailUrlForResource(res)
        : null;
    if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
      return _ThumbnailCard(
          res: res,
          parent: parent,
          bible: bible,
          onTap: onTap,
          thumbnailUrl: thumbnailUrl,
          thumbnailSize: iconSize ?? 80);
    } else {
      return _DefaultCard(res: res, parent: parent, bible: bible, onTap: onTap, iconSize: iconSize);
    }
  }
}

class _ThumbnailCard extends StatelessWidget {
  final Resource res;
  final Resource parent;
  final Bible bible;
  final VoidCallback onTap;
  final String thumbnailUrl;
  final double thumbnailSize;

  const _ThumbnailCard({
    Key key,
    @required this.res,
    @required this.parent,
    @required this.onTap,
    @required this.bible,
    @required this.thumbnailUrl,
    @required this.thumbnailSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _Card(
      cornerRadius: 0,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 12, top: 8, right: 8, bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _Card(
                padding: EdgeInsets.zero,
                elevation: 2,
                child: TecImage(url: thumbnailUrl, width: thumbnailSize, height: thumbnailSize),
              ),
            ),
            Expanded(
              child: _TitleEtcColumn(res: res, parent: parent, bible: bible, onTap: onTap),
            ),
          ],
        ),
      ),
    );
  }
}

class _DefaultCard extends StatelessWidget {
  final Resource res;
  final Resource parent;
  final Bible bible;
  final VoidCallback onTap;
  final double iconSize;

  const _DefaultCard(
      {Key key,
      @required this.res,
      @required this.parent,
      @required this.bible,
      @required this.onTap,
      this.iconSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _Card(
      cornerRadius: 0,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 12, top: 12, right: 8, bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _iconForResource(res, parent, iconSize),
            ),
            Expanded(child: _TitleEtcColumn(res: res, parent: parent, bible: bible, onTap: onTap)),
            if (res.hasType(ResourceType.folder)) const Center(child: Icon(Icons.navigate_next)),
          ],
        ),
      ),
    );
  }
}

class _TitleEtcColumn extends StatelessWidget {
  final Resource res;
  final Resource parent;
  final Bible bible;
  final VoidCallback onTap;

  const _TitleEtcColumn({
    Key key,
    @required this.res,
    @required this.parent,
    @required this.bible,
    @required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final refStyle = isNullOrEmpty(res.title) ? _titleStyle : _subtitleStyle;

    if (res.hasType(ResourceType.reference)) {
      return _ReferenceWidget(res: res, bible: bible);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isNotNullOrEmpty(res.title)) ...[
          Text(res.title, style: _titleStyle),
          const SizedBox(height: 4),
        ],
        if (bible != null && isNotNullOrZero(res.book) && isNotNullOrZero(res.chapter)) ...[
          Text(bible.titleWithResource(res), style: refStyle),
        ],
        if (isNotNullOrEmpty(res.caption)) ...[
          const SizedBox(height: 4),
          Text(
            res.caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

extension on Bible {
  String titleWithResource(Resource res) {
    if (res?.book == null || res?.chapter == null) return '';
    final bookAndChapter = titleWithBookAndChapter(res.book, res.chapter);
    if (isNotNullOrZero(res.verse)) {
      if (isNotNullOrZero(res.endVerse)) {
        return '$bookAndChapter:${res.verse}-${res.endVerse}';
      }
      return '$bookAndChapter:${res.verse}';
    }
    return bookAndChapter;
  }
}

extension on Resource {
  Reference asReference() => book == null || book == 0 || chapter == null || chapter == 0
      ? null
      : Reference(
          volume: volumeId,
          book: book,
          chapter: chapter,
          verse: verse,
          endVerse: endVerse == null || endVerse == 0 ? null : endVerse);
}

class _ReferenceWidget extends StatelessWidget {
  final Resource res;
  final Bible bible;

  const _ReferenceWidget({Key key, @required this.res, @required this.bible}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (bible == null || res?.book == null || res?.chapter == null) {
      return Text('ERROR: Invalid data, Bible: ${bible?.abbreviation}, resource: ${res.toJson()}');
    }

    if (isNotNullOrEmpty(res.verseText)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(bible.titleWithResource(res), style: _titleStyle),
          const SizedBox(height: 4),
          Text(res.verseText)
        ],
      );
    }

    return BlocProvider(
      create: (context) {
        final ref = res.asReference();
        return VerseTextBloc(ref)..updateWith(bible?.referenceAndVerseTextWith(ref));
      },
      child: BlocBuilder<VerseTextBloc, ReferenceAndVerseText>(
        builder: (context, result) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(result.reference.label(), style: _titleStyle),
              const SizedBox(height: 4),
              if (result.verseText?.isEmpty ?? true)
                const LoadingIndicator()
              else
                Text(result.allVerseText())
            ],
          );

          // return vt == null || vt.length == 0 ? const LoadingIndicator() : vt.;
        },
      ),
    );
  }
}

extension on ReferenceAndVerseText {
  String allVerseText() {
    final buff = StringBuffer();
    int prevVerse;
    for (final vt in verseText.values) {
      if (buff.isNotEmpty) {
        (prevVerse + 1 < vt.verse) ? buff.writeln() : buff.write(' ');
        buff.write('[${vt.verse}');
        if (vt.endVerse > vt.verse) buff.write('-${vt.endVerse}');
        buff.write('] ');
        prevVerse = vt.endVerse;
      }
      buff.write(vt.text);
    }
    return buff.toString();
  }
}

class VerseTextBloc extends Cubit<ReferenceAndVerseText> {
  VerseTextBloc(Reference ref) : super(ReferenceAndVerseText(ref, LinkedHashMap<int, VerseText>()));

  Future<void> updateWith(Future<ErrorOrValue<ReferenceAndVerseText>> futureResult) async {
    final result = await futureResult;
    emit(result?.value ??
        ReferenceAndVerseText(
          state.reference,
          {
            state.reference.verse: VerseText(
                verse: state.reference.verse,
                text: result?.error?.toString() ?? 'Error loading verse text.')
          }.asLinkedHashMap(),
        ));
  }
}

extension AsLinkedHashMapExtOnMap<K, V> on Map<K, V> {
  // In Dart, the generic `Map` type is implemented internally as a `LinkedHashMap`.
  LinkedHashMap<K, V> asLinkedHashMap() => this as LinkedHashMap<K, V>;
}

Icon _iconForResource(Resource res, Resource parent, double size) {
  switch (res.baseType) {
    case ResourceType.folder:
      if (parent?.id == 0 ?? true) {
        switch (res.title) {
          case 'Maps':
            return Icon(Icons.public, size: size, color: Colors.blue);
          case 'Charts':
            return Icon(Icons.poll_outlined, size: size, color: Colors.red);
          case 'Images':
            return Icon(Icons.insert_photo_outlined, size: size, color: Colors.green);
          case 'Articles':
            return Icon(Icons.article_outlined, size: size, color: Colors.orange);
          default:
            return Icon(Icons.folder_outlined, size: size);
        }
      } else {
        return Icon(Icons.folder_outlined, size: size);
      }
      break;

    case ResourceType.image:
    case ResourceType.video:
    case ResourceType.interactive:
    case ResourceType.timeline:
      return Icon(Icons.insert_photo_outlined, size: size, color: Colors.green);
    case ResourceType.map:
      return Icon(Icons.public, size: size, color: Colors.blue);
    case ResourceType.chart:
      return Icon(Icons.poll_outlined, size: size, color: Colors.red);
    case ResourceType.article:
    case ResourceType.studyNote:
    case ResourceType.introduction:
    case ResourceType.question:
    case ResourceType.link:
    case ResourceType.reference:
    case ResourceType.folderDevo:
    default:
      return Icon(Icons.article_outlined, size: size, color: Colors.orange);
      break;
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double cornerRadius;

  // Material
  final MaterialType materialType;
  final double elevation;
  final Color color;
  final Color shadowColor;
  final TextStyle textStyle;
  final BorderRadiusGeometry borderRadius;
  final ShapeBorder shape;
  final bool borderOnForeground;
  final Clip clipBehavior;

  // InkWell
  final GestureTapCallback onTap;
  final GestureTapCallback onLongPress;
  final Color splashColor;
  final Color highlightColor;

  const _Card({
    Key key,
    @required this.child,
    this.padding,
    this.cornerRadius,
    this.materialType = MaterialType.canvas,
    this.elevation = 0,
    this.color,
    this.shadowColor,
    this.textStyle,
    this.borderRadius,
    this.shape,
    this.borderOnForeground = true,
    this.clipBehavior = Clip.none,
    this.onTap,
    this.onLongPress,
    this.splashColor,
    this.highlightColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.all(defaultPaddingWith(context)),
      child: Material(
        type: materialType,
        elevation: elevation,
        color: color ?? Theme.of(context).backgroundColor,
        shadowColor: shadowColor,
        borderRadius: borderRadius ?? BorderRadius.all(Radius.circular(cornerRadius ?? 16.0)),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.passthrough,
          children: <Widget>[
            child,
            if (onTap != null || onLongPress != null)
              Positioned.fill(
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: onTap,
                    onLongPress: onLongPress,
                    splashColor: splashColor, // ?? Colors.grey.withOpacity(0.5),
                    highlightColor: highlightColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
