import 'package:flutter/material.dart';
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

class StudyResCard extends StatelessWidget {
  final Resource res;
  final Resource parent;
  final VoidCallback onTap;

  const StudyResCard({Key key, @required this.res, @required this.parent, @required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl =
        VolumesRepository.shared.volumeWithId(res.volumeId)?.thumbnailUrlForResource(res);
    if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
      return _Card(child: TecImage(url: thumbnailUrl, height: 100), onTap: onTap);
    } else {
      return InkWell(
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
              Expanded(child: Text(res.title)),
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
  final GestureTapCallback onTap;
  final GestureTapCallback onLongPress;
  final Color color;
  final Color boxShadowColor;
  final double elevation;
  final double padding;
  final double cornerRadius;
  final bool noSplashOrHighlight;

  const _Card({
    Key key,
    @required this.child,
    this.onTap,
    this.onLongPress,
    this.color = Colors.white,
    this.boxShadowColor,
    this.noSplashOrHighlight = false,
    this.elevation = 7,
    this.padding,
    this.cornerRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cornerRadius = this.cornerRadius ?? 16.0;
    return Padding(
      padding: EdgeInsets.all(padding ?? defaultPaddingWith(context)),
      child: Material(
        elevation: elevation,
        borderRadius: BorderRadius.all(Radius.circular(cornerRadius)),
        clipBehavior: Clip.hardEdge,
        // child: Container(
        //   decoration: boxDecoration(
        //     color: color,
        //     cornerRadius: cornerRadius,
        //     boxShadow: elevation == 0
        //         ? null
        //         : boxShadow(
        //             color: boxShadowColor ?? Colors.black26,
        //             offset: Offset(0, elevation - 1),
        //             blurRadius: elevation),
        //   ),
        //   child: ClipRRect(
        //     borderRadius: BorderRadius.all(Radius.circular(cornerRadius)),
        child: Stack(
          fit: StackFit.passthrough,
          children: <Widget>[
            child,
            if (onTap != null)
              Positioned.fill(
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    splashColor:
                        noSplashOrHighlight ? Colors.transparent : Colors.grey.withOpacity(0.5),
                    highlightColor: noSplashOrHighlight ? Colors.transparent : null,
                    onTap: onTap,
                    onLongPress: onLongPress,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
