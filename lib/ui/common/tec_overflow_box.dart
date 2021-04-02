import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
// import 'package:tec_util/tec_util.dart';

class TecOverflowBox extends SingleChildRenderObjectWidget {
  final double minWidth;
  final double maxWidth;
  final double minHeight;
  final double maxHeight;

  const TecOverflowBox(
      {Key key, this.minWidth, this.maxWidth, this.minHeight, this.maxHeight, Widget child})
      : super(key: key, child: child);

  @override
  RenderTecOverflowBox createRenderObject(BuildContext context) {
    return RenderTecOverflowBox(
      childConstraints: _childConstraints,
    );
  }

  BoxConstraints get _childConstraints {
    return BoxConstraints(
        minWidth: minWidth ?? 0,
        maxWidth: maxWidth ?? double.infinity,
        minHeight: minHeight ?? 0,
        maxHeight: maxHeight ?? double.infinity);
  }

  @override
  void updateRenderObject(BuildContext context, RenderTecOverflowBox renderObject) {
    renderObject.childConstraints = _childConstraints;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('minWidth', minWidth, defaultValue: null))
      ..add(DoubleProperty('maxWidth', maxWidth, defaultValue: null))
      ..add(DoubleProperty('minHeight', minHeight, defaultValue: null))
      ..add(DoubleProperty('maxHeight', maxHeight, defaultValue: null));
  }
}

class RenderTecOverflowBox extends RenderProxyBox {
  RenderTecOverflowBox({
    RenderBox child,
    @required BoxConstraints childConstraints,
  })  : assert(childConstraints != null),
        assert(childConstraints.debugAssertIsValid()),
        _childConstraints = childConstraints,
        super(child);

  BoxConstraints get childConstraints => _childConstraints;
  BoxConstraints _childConstraints;
  set childConstraints(BoxConstraints value) {
    assert(value != null);
    assert(value.debugAssertIsValid());
    if (_childConstraints == value) return;
    _childConstraints = value;
    markNeedsLayout();
  }

  /*
  @override
  double computeMinIntrinsicWidth(double height) {
    double width;
    if (childConstraints.hasBoundedWidth && childConstraints.hasTightWidth) {
      width = childConstraints.minWidth;
    } else {
      width = super.computeMinIntrinsicWidth(height);
      assert(width.isFinite);
      if (!childConstraints.hasInfiniteWidth) {
        width = childConstraints.constrainWidth(width);
      }
    }
    dmPrint('computeMinIntrinsicWidth($height) => $width');
    return width;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    double width;
    if (childConstraints.hasBoundedWidth && childConstraints.hasTightWidth) {
      width = childConstraints.minWidth;
    } else {
      width = super.computeMaxIntrinsicWidth(height);
      assert(width.isFinite);
      if (!childConstraints.hasInfiniteWidth) {
        width = childConstraints.constrainWidth(width);
      }
    }
    dmPrint('computeMaxIntrinsicWidth($height) => $width');
    return width;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    double height;
    if (childConstraints.hasBoundedHeight && childConstraints.hasTightHeight) {
      height = childConstraints.minHeight;
    } else {
      height = super.computeMinIntrinsicHeight(width);
      assert(height.isFinite);
      if (!childConstraints.hasInfiniteHeight) {
        height = childConstraints.constrainHeight(height);
      }
    }
    dmPrint('computeMinIntrinsicHeight($width) => $height');
    return height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    double height;
    if (childConstraints.hasBoundedHeight && childConstraints.hasTightHeight) {
      height = childConstraints.minHeight;
    } else {
      height = super.computeMaxIntrinsicHeight(width);
      assert(height.isFinite);
      if (!childConstraints.hasInfiniteHeight) {
        height = childConstraints.constrainHeight(height);
      }
    }
    dmPrint('computeMaxIntrinsicHeight($width) => $height');
    return height;
  }
  */

  @override
  Size computeDryLayout(BoxConstraints constraints) => _computeLayout();

  @override
  void performLayout() {
    size = _computeLayout();
  }

  Size _computeLayout() {
    if (child != null) {
      final c = childConstraints.enforceIfNotBounded(constraints);
      // dmPrint('calling child.layout($c)');
      child.layout(c, parentUsesSize: true);
      if (childConstraints.hasBoundedWidth) {
        if (!childConstraints.hasBoundedHeight) {
          return Size(
            childConstraints.enforce(constraints).constrain(Size.zero).width,
            child.size.height,
          );
        }
      } else if (childConstraints.hasBoundedHeight) {
        return Size(
          child.size.width,
          childConstraints.enforce(constraints).constrain(Size.zero).height,
        );
      }
    }
    return childConstraints.enforce(constraints).constrain(Size.zero);
  }

  @override
  void debugPaintSize(PaintingContext context, Offset offset) {
    super.debugPaintSize(context, offset);
    assert(() {
      Paint paint;
      if (child == null || child.size.isEmpty) {
        paint = Paint()..color = const Color(0x90909090);
        context.canvas.drawRect(offset & size, paint);
      }
      return true;
    }());
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<BoxConstraints>('childConstraints', childConstraints));
  }
}

extension TecOverflowBoxExtOnBoxConstraints on BoxConstraints {
  BoxConstraints enforceIfNotBounded(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: hasBoundedWidth
          ? minWidth
          : minWidth.clamp(constraints.minWidth, constraints.maxWidth).toDouble(),
      maxWidth: hasBoundedWidth
          ? maxWidth
          : maxWidth.clamp(constraints.minWidth, constraints.maxWidth).toDouble(),
      minHeight: hasBoundedHeight
          ? minHeight
          : minHeight.clamp(constraints.minHeight, constraints.maxHeight).toDouble(),
      maxHeight: hasBoundedHeight
          ? maxHeight
          : maxHeight.clamp(constraints.minHeight, constraints.maxHeight).toDouble(),
    );
  }
}
