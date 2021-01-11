import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'tec_scroll_listener.dart';

class TecAutoHideAppBar extends StatelessWidget {
  final PreferredSizeWidget appBar;
  final Widget body;
  final Duration animationDuration;

  const TecAutoHideAppBar({
    Key key,
    @required this.appBar,
    @required this.body,
    this.animationDuration,
  })  : assert(appBar != null && body != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<_BoolBloc>(
      create: (_) => _BoolBloc(state: true),
      child: Builder(
        builder: (context) {
          return Stack(
            children: [
              TecScrollListener(
                axisDirection: AxisDirection.down,
                changedDirection: (direction) {
                  if (direction == ScrollDirection.reverse) {
                    context.read<_BoolBloc>()?.update(to: true);
                  } else if (direction == ScrollDirection.forward) {
                    context.read<_BoolBloc>()?.update(to: false);
                  }
                },
                child: body,
              ),
              BlocBuilder<_BoolBloc, bool>(
                builder: (context, show) {
                  return AnimatedPositioned(
                    top: show ? 0.0 : -(appBar?.preferredSize?.height ?? 100.0),
                    left: 0.0,
                    right: 0.0,
                    duration: animationDuration ?? const Duration(milliseconds: 300),
                    child: Container(
                      color: Theme.of(context).backgroundColor,
                      child: appBar,
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BoolBloc extends Cubit<bool> {
  _BoolBloc({bool state}) : super(state);
  void update({bool to}) => emit(to);
}

class PreferredSizeWidgetWithPadding extends StatelessWidget implements PreferredSizeWidget {
  final EdgeInsets padding;
  final PreferredSizeWidget widget;

  const PreferredSizeWidgetWithPadding({Key key, @required this.padding, @required this.widget})
      : assert(padding != null && widget != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Center(child: widget),
      );

  @override
  Size get preferredSize =>
      Size.fromHeight(widget.preferredSize.height + padding.top + padding.bottom);
}

class PreferredSizeColumn extends StatelessWidget implements PreferredSizeWidget {
  final List<PreferredSizeWidget> children; // = const <Widget>[],
  final EdgeInsets padding;
  final MainAxisAlignment mainAxisAlignment; // = MainAxisAlignment.start,
  final CrossAxisAlignment crossAxisAlignment; // = CrossAxisAlignment.center,
  final TextDirection textDirection;
  final VerticalDirection verticalDirection; // = VerticalDirection.down,
  final TextBaseline textBaseline;

  const PreferredSizeColumn({
    Key key,
    @required this.children,
    this.padding,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
  })  : assert(children != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Column(
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: crossAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          textBaseline: textBaseline,
          children: children,
        ),
      );

  @override
  Size get preferredSize =>
      Size.fromHeight(children.fold<double>(0.0, (prev, el) => prev + el.preferredSize.height) +
          padding.top +
          padding.bottom);
}
