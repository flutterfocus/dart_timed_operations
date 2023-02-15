/// This library provides classes based on timed operations such as Debounce
/// Throttle operations.
///
/// Additionally, it provides optional callbacks to handle different states and
/// outcomes, such as errors, waiting states, null or empty data, and successful completion of the operation. 
///
/// Debounce limits the rate at which a function can be called by delaying
/// subsequent calls for a specified duration. This can help reduce the number
/// of times a function is called when a user is rapidly firing events, such as
/// typing in a search bar or scrolling. It also handles errors and different
/// states of data, such as waiting, null or empty data.
///
/// Throttle limits the frequency at which a function is called by executing it
/// at a regular interval. This can help avoid the overhead of executing a
/// function too frequently, such as sending frequent requests to a server or
/// processing a large amount of data. It also provides options for leading or
/// trailing execution and handles errors and different states of data.
library timed_operations;

import 'dart:async';
import 'package:ff_trycatch/ff_trycatch.dart';

typedef OnTimeout = void Function()?;
typedef OnError = void Function(Object error, StackTrace stackTrace)?;
typedef OnThrottle = void Function()?;
typedef OnWaiting = void Function()?;
typedef OnSuccess = void Function<T>(T data)?;
typedef OnNull = void Function()?;
typedef OnEmpty = void Function()?;

class Throttle {
  static final Map<Object, Timer?> _throttleTimers = {};

  /// Throttles a synchronous operation by preventing it from being executed more
  /// frequently than the specified `throttle` duration, and executes a success
  /// callback with the result of the operation.
  ///
  /// If the operation is already throttled, the `onThrottle` callback is executed
  /// and the operation is not performed.
  ///
  /// If the operation returns null, the `onNull` callback is executed.
  ///
  /// If the operation returns an empty iterable or map, the `onEmpty` callback is
  /// executed.
  ///
  /// If the operation throws an error, the `onError` callback is executed.
  ///
  /// The `onSuccess` callback is executed with the result of the operation if it
  /// completes successfully.
  ///
  /// The `callId` parameter is used to uniquely identify each operation. The
  /// `throttle` parameter determines the duration of the throttling, and defaults
  /// to 1 second.
  ///
  /// If you need to perform asynchronous operations, use the `throttleFuture`
  /// method instead.
  ///
  /// Usage:
  ///
  /// ```dart
  /// throttle<int>(
  ///   callId: 'example',
  ///   operation: () => 1 + 1,
  ///   onThrottle: () => print('Operation is throttled'),
  ///   onNull: () => print('Operation returned null'),
  ///   onEmpty: () => print('Operation returned an empty iterable or map'),
  ///   onSuccess: (result) => print('Operation result: $result'),
  ///   throttle: const Duration(milliseconds: 500),
  /// );
  /// ```
  static void sync<T>({
    required String callId,
    required Function() operation,
    OnThrottle onThrottle,
    OnError? onError,
    OnNull? onNull,
    OnEmpty? onEmpty,
    required void Function(T data) onSuccess,
    Duration throttle = const Duration(seconds: 1),
  }) {
    if (_throttleTimers.containsKey(callId) &&
        _throttleTimers[callId]?.isActive == true) {
      onThrottle?.call();
      return;
    }

    _throttleTimers[callId] = Timer(throttle, () {});

    TryCatch.sync<T>(
      operation: () => operation(),
      onNull: onNull,
      onEmpty: onEmpty,
      onSuccess: onSuccess,
      onError: (e, s) => onError?.call(e, s),
    );
  }

  /// Throttles the execution of an asynchronous operation and handles its result or errors
  /// based on the given callback functions. The `callId` parameter is used to identify
  /// the operation and avoid concurrent executions. The `operation` parameter is the
  /// asynchronous operation to be throttled, and `duration` is the duration of the
  /// throttling period.
  ///
  /// The optional `onTimeout`, `onError`, `onWaiting`, `onNull`, `onEmpty`, and `onThrottle`
  /// parameters are callbacks that are called depending on the result or error of the
  /// operation or if the operation is waiting or is throttled. The required `onSuccess`
  /// parameter is a callback that is called with the result of the operation if it is
  /// successful.
  ///
  /// The optional `timeout` parameter is the maximum duration that the operation is
  /// allowed to execute before it times out.
  ///
  /// Usage:
  ///
  /// ```dart
  /// await Throttle.async<int>(
  ///   callId: 'example',
  ///   operation: () async {
  ///     // perform some async operation
  ///     await Future.value(100);
  ///   },
  ///   onThrottle: () => print('Operation is throttled'),
  ///   onNull: () => print('Operation returned null'),
  ///   onEmpty: () => print('Operation returned an empty iterable or map'),
  ///   onSuccess: (result) => print('Operation result: $result'),
  ///   duration: const Duration(milliseconds: 500),
  ///   timeout: const Duration(seconds: 5),
  /// );
  /// ```
  static Future<void> async<T>({
    required String callId,
    required Future<T> operation,
    OnTimeout onTimeout,
    OnError onError,
    OnWaiting onWaiting,
    OnNull onNull,
    OnEmpty onEmpty,
    OnThrottle onThrottle,
    required void Function(T data) onSuccess,
    Duration duration = const Duration(seconds: 1),
    Duration timeout = const Duration(milliseconds: 0),
  }) async {
    if (_throttleTimers.containsKey(callId) &&
        _throttleTimers[callId]?.isActive == true) {
      onThrottle?.call();
      return;
    }

    _throttleTimers[callId] = Timer(duration, () async {
      _throttleTimers.remove(callId);
    });

    await TryCatch.async<T>(
      future: operation,
      onNull: onNull,
      onEmpty: onEmpty,
      onSuccess: onSuccess,
      onTimeout: onTimeout,
      onWaiting: onWaiting,
      onError: (e, s) => onError?.call(e, s),
      timeout: timeout,
    );
  }
}

/// A class that provides a simple mechanism to debounce multiple calls to a
/// synchronous or asynchronous operation. Debouncing is used to limit the
/// number of calls to the same operation within a specific duration.
///
/// The class has two methods: `sync()` and `async()`. The `sync()` method runs a
/// synchronous operation while the `async()` method runs an asynchronous
/// operation. Both methods take a `callId`, an `operation` to execute, and a
/// `duration` that specifies the wait time before executing the operation.
///
/// You can provide optional callbacks to handle different states and outcomes.
/// The `onError` callback handles errors that occur during the operation. The
/// `onWaiting` callback handles waiting states. The `onNull` callback handles
/// null data. The `onEmpty` callback handles empty data. The `onSuccess` callback
/// handles the successful completion of the operation.
class Debounce {
  static final Map<Object, Timer?> _debounceTimers = {};

  /// Runs a synchronous operation with a debounce mechanism to limit multiple
  /// calls to the same operation. This method waits for a specified duration
  /// after a call with a specific `callId` has been made before running the
  /// operation.
  ///
  /// When the operation is complete, the `onSuccess` callback is called with the
  /// result. You can also provide optional callbacks to handle errors, waiting
  /// states, null and empty data.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// Deounce.sync<String>(
  ///   callId: 'my_call_id',
  ///   operation: fetchSomeData,
  ///   onSuccess: (data) => print('Got data: $data'),
  /// );
  /// ```
  static void sync<T>({
    required String callId,
    required Function() operation,
    OnError onError,
    OnWaiting onWaiting,
    OnNull onNull,
    OnEmpty onEmpty,
    required void Function(T data) onSuccess,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    if (_debounceTimers.containsKey(callId)) {
      _debounceTimers[callId]?.cancel();
    }

    _debounceTimers[callId] = Timer(duration, () {
      TryCatch.sync<T>(
        operation: () => operation(),
        onError: onError,
        onNull: onNull,
        onEmpty: onEmpty,
        onSuccess: onSuccess,
      );
      _debounceTimers.remove(callId);
    });
  }

  /// Runs an asynchronous operation with a debounce mechanism to limit multiple
  /// calls to the same operation. This method waits for a specified duration
  /// after a call with a specific `callId` has been made before running the
  /// operation.
  ///
  /// When the operation is complete, the `onSuccess` callback is called with the
  /// result. You can also provide optional callbacks to handle errors, waiting
  /// states, null and empty data.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// Debounce.async<String>(
  ///   callId: 'my_call_id',
  ///   operation: fetchSomeData(),
  ///   onSuccess: (data) => print('Got data: $data'),
  /// );
  /// ```
  static void async<T>({
    required Object callId,
    required Future<T> operation,
    OnError onError,
    OnWaiting onWaiting,
    OnNull onNull,
    OnEmpty onEmpty,
    required void Function(T data) onSuccess,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    if (_debounceTimers.containsKey(callId)) {
      _debounceTimers[callId]?.cancel();
    }

    _debounceTimers[callId] = Timer(duration, () async {
      await TryCatch.async<T>(
        future: operation,
        onError: onError,
        onWaiting: onWaiting,
        onNull: onNull,
        onEmpty: onEmpty,
        onSuccess: onSuccess,
      );
      _debounceTimers.remove(callId);
    });
  }
}
