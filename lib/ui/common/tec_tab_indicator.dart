import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

///
/// Tab indicator influenced by Google's Material Design 2 tab indicator design.
///
class TecTabIndicator extends Decoration {
  // Inspired by:
  // https://github.com/westdabestdb/md2_tab_indicator/blob/master/lib/md2_tab_indicator.dart

  final double indicatorHeight;
  final Color indicatorColor;
  final TecTabIndicatorSize indicatorSize;

  const TecTabIndicator({
    @required this.indicatorHeight,
    @required this.indicatorColor,
    @required this.indicatorSize,
  });

  @override
  _TecTabPainter createBoxPainter([VoidCallback onChanged]) {
    return _TecTabPainter(this, onChanged);
  }
}

class _TecTabPainter extends BoxPainter {
  final TecTabIndicator decoration;

  _TecTabPainter(this.decoration, VoidCallback onChanged)
      : assert(decoration != null),
        super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration != null);
    assert(configuration.size != null);

    Rect rect;
    if (decoration.indicatorSize == TecTabIndicatorSize.full) {
      rect = Offset(offset.dx, (configuration.size.height - decoration.indicatorHeight ?? 3)) &
          Size(configuration.size.width, decoration.indicatorHeight ?? 3);
    } else if (decoration.indicatorSize == TecTabIndicatorSize.normal) {
      rect = Offset(offset.dx + 6, (configuration.size.height - decoration.indicatorHeight ?? 3)) &
          Size(configuration.size.width - 12, decoration.indicatorHeight ?? 3);
    } else if (decoration.indicatorSize == TecTabIndicatorSize.tiny) {
      rect = Offset(offset.dx + configuration.size.width / 2 - 8,
              (configuration.size.height - decoration.indicatorHeight ?? 3)) &
          Size(16, decoration.indicatorHeight ?? 3);
    }

    final paint = Paint()
      ..color = decoration.indicatorColor ?? const Color(0xff1967d2)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
        RRect.fromRectAndCorners(rect,
            topRight: const Radius.circular(8), topLeft: const Radius.circular(8)),
        paint);
  }
}

enum TecTabIndicatorSize {
  tiny,
  normal,
  full,
}

class BubbleTabIndicator extends Decoration {
  final Color color;
  const BubbleTabIndicator({this.color});
  @override
  _BubblePainter createBoxPainter([VoidCallback onChanged]) {
    return _BubblePainter(this, onChanged, color);
  }
}

class _BubblePainter extends BoxPainter {
  final BubbleTabIndicator decoration;
  final Color color;

  _BubblePainter(this.decoration, VoidCallback onChanged, this.color)
      : assert(decoration != null),
        super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration != null);
    assert(configuration.size != null);

    //offset is the position from where the decoration should be drawn.
    //configuration.size tells us about the height and width of the tab.
    const indicatorHeight = 25.0;
    const strokeWidth = 2.0;
    final rect = Offset(offset.dx, (configuration.size.height / 2) - indicatorHeight / 2) &
        Size(configuration.size.width, indicatorHeight);
    const padding = EdgeInsets.symmetric(vertical: 3.0, horizontal: 15.0);
    final indicator = padding.resolve(configuration.textDirection).inflateRect(rect);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawRRect(RRect.fromRectAndRadius(indicator, const Radius.circular(15.0)), paint);
  }
}
