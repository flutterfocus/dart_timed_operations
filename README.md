# Timed Operations

![Flutter Focus Cover](https://github.com/flutterfocus/dart_timed_operations/blob/main/assets/images/github-cover-dart_timed_operations.png?raw=true)

[![YouTube Badge](https://img.shields.io/badge/YouTube-Channel-informational?style=flat&logo=youtube&logoColor=red&color=red)](https://youtube.com/@flutterfocus) [![Twitter Badge](https://img.shields.io/badge/@Twitter-Profile-informational?style=flat&logo=twitter&logoColor=lightblue&color=1CA2F1)](https://twitter.com/flutterfocus) [![Discord Badge](https://img.shields.io/discord/1048138797893828608?color=blue&label=Discord&logo=discord)](https://discord.gg/rx8mzKzjFM) [![Reddit](https://img.shields.io/reddit/user-karma/link/flutterfocus?style=flat&logo=reddit&label=Reddit)](https://reddit.com/user/flutterfocus)
Timed Operations provides better handling of timed operations such as Debounce Throttle operations.

Additionally, it provides optional callbacks to handle different states and
outcomes, such as errors, waiting states, null or empty data, and successful completion of the operation.

## Usage

### `Throttle.sync()`
Throttles a synchronous operation by preventing it from being executed more
frequently than the specified `throttle` duration, and executes a success
callback with the result of the operation.

```dart
Throttle.sync<int>(
  callId: 'example',
  operation: () => 1 + 1,
  onThrottle: () => print('Operation is throttled'),
  onNull: () => print('Operation returned null'),
  onEmpty: () => print('Operation returned an empty iterable or map'),
  onSuccess: (result) => print('Operation result: $result'),
  throttle: const Duration(milliseconds: 500),
);

### `Throttle.async()`
  /// Throttles the execution of an asynchronous operation and handles its result or errors
  /// based on the given callback functions. The `callId` parameter is used to identify
  /// the operation and avoid concurrent executions. The `operation` parameter is the
  /// asynchronous operation to be throttled, and `duration` is the duration of the
  /// throttling period.

```dart
await Throttle.async<int>(
  callId: 'example',
  operation: () async {
    // perform some async operation
    await Future.value(100);
  },
  onThrottle: () => print('Operation is throttled'),
  onNull: () => print('Operation returned null'),
  onEmpty: () => print('Operation returned an empty iterable or map'),
  onSuccess: (result) => print('Operation result: $result'),
  duration: const Duration(milliseconds: 500),
  timeout: const Duration(seconds: 5),
);


### ❤️  Support Flutter Focus
- 🚀 [Github Sponsors](https://github.com/sponsors/flutterfocus)

### Need Mobile, Web or Video marketing services? 📱 🌐 📹
Flutter Focus offers bespoke services in multimedia storytelling by mixing Mobile, Web and Video.

[Find out more](https://flutterfocus.dev/services/).

```
