import 'package:tec_util/tec_util.dart' as tec;

///
/// Sometimes the inputs to a `Future` change before the `Future` completes, 
/// so a new `Future` is created and the results of the previous one should
/// be ignored. This class provides an easy way to handle that scenario.
///
/// First, create an instance of this class, passing in a `handler` function
/// that will be called with the future results.
///
/// Then call `updateWith(Future<T> future)` with the `Future`. When the
/// `Future` completes, the `handler` will be called with the results.
///
/// Each time the inputs to the `Future` change, call `updateWith` with the
/// new `Future`.
///
/// If `updateWith` is called with a new `Future` while waiting on an 
/// unfinished `Future`, the results of the unfinished `Future` will be 
/// ignored, i.e. the `handler` will not be called with the results of the 
/// unfinished `Future`.
///
/// The `cancel` method should be called when you are finished with the
/// instance, that way the `handler` will not be called with the results of
/// any pending `Future`.
///
class FutureHandler<T> {
  final void Function(T data, Object error) handler;

  FutureHandler(this.handler) : assert(handler != null);

  ///
  /// Updates the future, ignoring the results of any pending future, and
  /// when the future finishes, calls the handler with the resulting
  /// `data` or `error`.
  ///
  void updateWith(Future<T> future) => _update(future);

  void updateWithFutureErrorOrValue(Future<tec.ErrorOrValue<T>> future) => _update(future);

  void _update(Future future) {
    if (future == null) {
      cancel();
      return;
    }

    final callbackIdentity = Object();
    _activeCallbackIdentity = callbackIdentity;
    future.then<void>((dynamic data) {
      if (_activeCallbackIdentity == callbackIdentity) {
        if (data is tec.ErrorOrValue<T>) {
          handler(data.value, data.error);
        } else if (data is T) {
          handler(data, null);
        }
      }
      // ignore: avoid_types_on_closure_parameters
    }, onError: (Object error) {
      if (_activeCallbackIdentity == callbackIdentity) {
        handler(null, error);
      }
    });
  }

  ///
  /// Ignores the results of any pending future.
  ///
  void cancel() {
    _activeCallbackIdentity = null;
  }

  Object _activeCallbackIdentity;
}
