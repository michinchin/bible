import 'dart:async';

import 'package:flutter/widgets.dart';

typedef TecAsyncWidgetBuilder<T> = Widget Function(BuildContext context, T data, Object error);

class TecStreamBuilder<T> extends StatefulWidget {
  final Stream<T> stream;
  final T initialData;
  final TecAsyncWidgetBuilder<T> builder;

  const TecStreamBuilder({Key key, this.stream, this.initialData, this.builder}) : super(key: key);

  @override
  State<TecStreamBuilder<T>> createState() => _TecStreamBuilderState<T>();
}

class _TecStreamBuilderState<T> extends State<TecStreamBuilder<T>> {
  StreamSubscription<T> _subscription;
  T _data;
  Object _error;

  @override
  void initState() {
    super.initState();
    _data = widget.initialData;
    _subscribe();
  }

  @override
  void didUpdateWidget(TecStreamBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stream != widget.stream) {
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
    if (widget.stream != null) {
      _subscription = widget.stream.listen((data) {
        if (data != _data) {
          setState(() {
            print('TecStreamBuilder rebuilding, $data != $_data');
            _data = data;
          });
        }
        // ignore: avoid_types_on_closure_parameters
      }, onError: (Object error) => setState(() => _error = error));
    }
  }

  void _unsubscribe() {
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _error != null ? null : _data, _error);
}
