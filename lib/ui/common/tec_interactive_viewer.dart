import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'tec_auto_hide_app_bar.dart';

class TecInteractiveViewer extends StatelessWidget {
  final Widget child;
  final String caption;
  final Duration duration;
  final EdgeInsets boundaryMargin;
  final double minScale;
  final double maxScale;

  const TecInteractiveViewer({
    Key key,
    @required this.child,
    this.caption,
    this.duration,
    this.boundaryMargin = const EdgeInsets.all(60),
    this.minScale = 0.1,
    this.maxScale = 4.0,
  })  : assert(child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasCaption = caption?.isNotEmpty ?? false;

    if (hasCaption) {
      // If there's no `TecAutoHideAppBarBloc` ancestor in the widget tree, make one,
      // because _Caption needs it.
      final bloc = context.findBloc<TecAutoHideAppBarBloc>();
      if (bloc == null) {
        return BlocProvider<TecAutoHideAppBarBloc>(
          create: (_) => TecAutoHideAppBarBloc(),
          child: _build(context),
        );
      }
    }

    return _build(context);
  }

  Widget _build(BuildContext context) => GestureDetector(
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              InteractiveViewer(
                boundaryMargin: boundaryMargin,
                minScale: minScale ?? 0.1,
                maxScale: maxScale ?? 4.0,
                child: Center(child: child),
              ),
              if (caption?.isNotEmpty ?? false) _Caption(caption: caption, duration: duration),
            ],
          ),
        ),
        onTap: () => context.read<TecAutoHideAppBarBloc>()?.toggle(),
      );
}

class _Caption extends StatelessWidget {
  final String caption;
  final Duration duration;

  const _Caption({Key key, @required this.caption, this.duration})
      : assert(caption != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final _duration = duration ?? const Duration(milliseconds: 300);
    return BlocBuilder<TecAutoHideAppBarBloc, bool>(
      builder: (context, hide) {
        return AnimatedPositioned(
          duration: _duration,
          bottom: hide ? -100.0 : 0.0,
          right: 0,
          left: 0,
          child: IgnorePointer(
            child: AnimatedOpacity(
              duration: _duration,
              opacity: hide ? 0 : 1,
              child: Material(
                color: isDarkTheme ? const Color(0xCC333333) : const Color(0xCC666666),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      caption,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkTheme ? const Color(0xFFAAAAAA) : const Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

extension TecFindBlocExtOnBuildContext on BuildContext {
  ///
  /// Performs a lookup using the `BuildContext` to obtain
  /// the nearest ancestor `Cubit` of type [C].
  ///
  /// Calling this method is equivalent to calling:
  ///
  /// ```dart
  /// Provider.of<C>(context, listen: false)
  /// ```
  ///
  /// However, this function will not throw on the `ProviderNotFoundException` unless
  /// the types do not match.
  ///
  C findBloc<C extends Cubit<Object>>() {
    try {
      return Provider.of<C>(this, listen: false);
    } on ProviderNotFoundException catch (e) {
      if (e.valueType != C) rethrow;
      return null;
    }
  }
}
