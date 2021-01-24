import 'package:flutter/material.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

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

  const StudyResCard({
    Key key,
    @required this.res,
    @required this.parent,
    @required this.bible,
    @required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl =
        VolumesRepository.shared.volumeWithId(res.volumeId)?.thumbnailUrlForResource(res);
    if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
      return _ThumbnailCard(
          res: res, parent: parent, bible: bible, onTap: onTap, thumbnailUrl: thumbnailUrl);
    } else {
      return _DefaultCard(res: res, parent: parent, bible: bible, onTap: onTap);
    }
  }
}

class _ThumbnailCard extends StatelessWidget {
  final Resource res;
  final Resource parent;
  final Bible bible;
  final VoidCallback onTap;
  final String thumbnailUrl;

  const _ThumbnailCard({
    Key key,
    @required this.res,
    @required this.parent,
    @required this.onTap,
    @required this.bible,
    @required this.thumbnailUrl,
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
                child: TecImage(url: thumbnailUrl, width: 80, height: 80),
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

  const _DefaultCard({
    Key key,
    @required this.res,
    @required this.parent,
    @required this.bible,
    @required this.onTap,
  }) : super(key: key);

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
              child: Icon(_iconForResource(res, parent)),
            ),
            Expanded(child: _TitleEtcColumn(res: res, parent: parent, bible: bible, onTap: onTap)),
            if (res.hasType(ResourceType.folder))
              const Icon(
                Icons.navigate_next,
              ),
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
    final refStyle = tec.isNullOrEmpty(res.title) ? _titleStyle : _subtitleStyle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tec.isNotNullOrEmpty(res.title)) ...[
          Text(res.title, style: _titleStyle),
          const SizedBox(height: 4),
        ],
        if (bible != null && tec.isNotNullOrZero(res.book) && tec.isNotNullOrZero(res.chapter)) ...[
          Text(bible.titleWithBookAndChapter(res.book, res.chapter), style: refStyle),
        ],
        if (tec.isNotNullOrEmpty(res.caption)) ...[
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

IconData _iconForResource(Resource res, Resource parent) {
  switch (res.baseType) {
    case ResourceType.folder:
      if (parent?.id == 0 ?? true) {
        switch (res.title) {
          case 'Maps':
            return Icons.public;
          case 'Charts':
            return Icons.poll_outlined;
          case 'Images':
            return Icons.insert_photo_outlined;
          case 'Articles':
            return Icons.article_outlined;
          default:
            return Icons.folder_outlined;
        }
      } else {
        return Icons.folder_outlined;
      }
      break;

    case ResourceType.article:
    case ResourceType.studyNote:
    case ResourceType.introduction:
    case ResourceType.question:
    case ResourceType.image:
    case ResourceType.map:
    case ResourceType.chart:
    case ResourceType.link:
    case ResourceType.reference:
    case ResourceType.video:
    case ResourceType.interactive:
    case ResourceType.timeline:
    case ResourceType.folderDevo:
    default:
      return Icons.article_outlined;
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
