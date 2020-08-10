import 'dart:async';

import 'package:flutter/widgets.dart';

import 'tec_stream_builder.dart';

class TecFutureBuilder<T> extends StatefulWidget {
  final Future<T> Function() futureBuilder;
  final Future<T> future;
  final T initialData;
  final TecAsyncWidgetBuilder<T> builder;

  const TecFutureBuilder({
    Key key,
    this.future,
    this.futureBuilder,
    this.initialData,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

  @override
  State<TecFutureBuilder<T>> createState() => _TecFutureBuilderState<T>();
}

/// State for [TecFutureBuilder].
class _TecFutureBuilderState<T> extends State<TecFutureBuilder<T>> {
  Object _activeCallbackIdentity;
  Future<T> _future;
  Object _error;
  T _data;

  @override
  void initState() {
    super.initState();
    _data = widget.initialData;
    _subscribe();
  }

  @override
  void didUpdateWidget(TecFutureBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.future != widget.future || oldWidget.futureBuilder != widget.futureBuilder) {
      _unsubscribe();
      _subscribe();
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    if (widget.future != null) {
      _future = widget.future;
    } else if (widget.futureBuilder != null) {
      _future = widget.futureBuilder();
    }

    if (_future != null) {
      final callbackIdentity = Object();
      _activeCallbackIdentity = callbackIdentity;
      _future.then<void>((data) {
        if (_activeCallbackIdentity == callbackIdentity) {
          if (data != _data) {
            setState(() {
              // print('TecFutureBuilder rebuilding, $data != $_data');
              _data = data;
            });
          }
        }
        // ignore: avoid_types_on_closure_parameters
      }, onError: (Object error) {
        if (_activeCallbackIdentity == callbackIdentity) {
          setState(() => _error = error);
        }
      });
    }
  }

  void _unsubscribe() {
    _activeCallbackIdentity = null;
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _error != null ? null : _data, _error);
}
