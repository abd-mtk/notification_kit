import 'package:flutter/foundation.dart';

typedef LogSink = void Function(String tag, String message);

final class KitLogger {
  const KitLogger({required this.sink, this.tag = 'SignalPlus'});

  factory KitLogger.debug({final bool enabled = true, final String tag = 'SignalPlus'}) =>
      KitLogger(sink: enabled ? debugSink : silentSink, tag: tag);

  final LogSink sink;

  final String tag;

  KitLogger tagged(final String name) => KitLogger(sink: sink, tag: '$tag/$name');

  void info(final String message) => sink(tag, message);

  void error(final String message, final Object error, [final StackTrace stackTrace = StackTrace.empty]) {
    sink(tag, 'ERROR $message: $error${stackTrace == StackTrace.empty ? '' : '\n$stackTrace'}');
  }

  static void debugSink(final String tag, final String message) => debugPrint('[$tag] $message');

  static void silentSink(final String tag, final String message) {}
}
