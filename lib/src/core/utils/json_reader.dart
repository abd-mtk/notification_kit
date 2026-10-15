import 'package:fpdart/fpdart.dart';

import '../errors/exceptions.dart';

typedef JsonMap = Map<String, dynamic>;

abstract final class JsonReader {
  static JsonMap object(final Object? value, [final String context = 'body']) => switch (value) {
    final Map<String, dynamic> map => map,
    final Map<dynamic, dynamic> map => map.map((final dynamic key, final dynamic item) => MapEntry('$key', item)),
    _ => throw DecodeException('$context is not an object'),
  };

  static String string(final JsonMap json, final String key) => switch (json[key]) {
    final String value => value,
    _ => throw DecodeException('$key is not a string'),
  };

  static Option<String> optString(final JsonMap json, final String key) => switch (json[key]) {
    final String value => some(value),
    null => const None(),
    _ => throw DecodeException('$key is not a string'),
  };

  static int integer(final JsonMap json, final String key) => switch (json[key]) {
    final int value => value,
    final num value => value.toInt(),
    _ => throw DecodeException('$key is not an integer'),
  };

  static bool boolean(final JsonMap json, final String key) => switch (json[key]) {
    final bool value => value,
    _ => throw DecodeException('$key is not a boolean'),
  };

  static DateTime date(final JsonMap json, final String key) => Option.fromNullable(
    DateTime.tryParse(string(json, key)),
  ).getOrElse(() => throw DecodeException('$key is not a date'));

  static Option<DateTime> optDate(final JsonMap json, final String key) =>
      json[key] == null ? const None() : some(date(json, key));

  static JsonMap map(final JsonMap json, final String key) => object(json[key], key);

  static Option<JsonMap> optMap(final JsonMap json, final String key) =>
      json[key] == null ? const None() : some(map(json, key));

  static List<T> list<T>(final JsonMap json, final String key, final T Function(Object? item) parse) =>
      switch (json[key]) {
        final List<dynamic> items => items.map(parse).toList(growable: false),
        null => <T>[],
        _ => throw DecodeException('$key is not a list'),
      };

  static List<String> strings(final JsonMap json, final String key) => list(
    json,
    key,
    (final Object? item) => item is String ? item : throw DecodeException('$key has a non string item'),
  );

  static Map<String, String> stringMap(final JsonMap json, final String key) => switch (json[key]) {
    final Map<dynamic, dynamic> map => map.map(
      (final dynamic name, final dynamic value) => MapEntry('$name', value is String ? value : '$value'),
    ),
    null => const <String, String>{},
    _ => throw DecodeException('$key is not a map'),
  };

  static Option<Map<String, String>> optStringMap(final JsonMap json, final String key) =>
      json[key] == null ? const None() : some(stringMap(json, key));
}

abstract final class JsonWriter {
  static JsonMap compact(final Map<String, Option<Object>> fields) => <String, dynamic>{
    for (final MapEntry<String, Option<Object>> field in fields.entries)
      ...field.value.match(
        () => const <String, dynamic>{},
        (final Object value) => <String, dynamic>{field.key: value},
      ),
  };

  static String date(final DateTime value) => value.toUtc().toIso8601String();
}
