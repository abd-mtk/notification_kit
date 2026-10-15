mixin WireValue on Enum {
  String get wire;
}

abstract final class WireEnums {
  static T parse<T extends WireValue>(final List<T> values, final String raw, final T fallback) {
    for (final T value in values) {
      if (value.wire.toLowerCase() == raw.toLowerCase()) return value;
    }
    return fallback;
  }
}

enum ServiceLocale with WireValue {
  ar('ar'),
  en('en');

  const ServiceLocale(this.wire);

  @override
  final String wire;

  static ServiceLocale parse(final String raw) => WireEnums.parse(values, raw, ar);
}

enum DevicePlatform with WireValue {
  android('Android'),
  ios('iOS'),
  unknown('Unknown');

  const DevicePlatform(this.wire);

  @override
  final String wire;

  static DevicePlatform parse(final String raw) => WireEnums.parse(values, raw, unknown);
}

enum PushPermission with WireValue {
  granted('Granted'),
  denied('Denied'),
  provisional('Provisional'),
  notDetermined('NotDetermined');

  const PushPermission(this.wire);

  @override
  final String wire;

  bool get canDeliver => this == granted || this == provisional;

  static PushPermission parse(final String raw) => WireEnums.parse(values, raw, notDetermined);
}

enum TokenStatus with WireValue {
  valid('Valid'),
  invalid('Invalid'),
  expired('Expired'),
  unknown('Unknown');

  const TokenStatus(this.wire);

  @override
  final String wire;

  static TokenStatus parse(final String raw) => WireEnums.parse(values, raw, unknown);
}

enum WeekDay with WireValue {
  sun('Sun'),
  mon('Mon'),
  tue('Tue'),
  wed('Wed'),
  thu('Thu'),
  fri('Fri'),
  sat('Sat');

  const WeekDay(this.wire);

  @override
  final String wire;

  static WeekDay parse(final String raw) => WireEnums.parse(values, raw, sun);
}

enum Lane with WireValue {
  critical('Critical'),
  transactional('Transactional'),
  bulk('Bulk');

  const Lane(this.wire);

  @override
  final String wire;

  static Lane parse(final String raw) => WireEnums.parse(values, raw, transactional);
}

enum DeliveryEventType with WireValue {
  created('Created'),
  suppressed('Suppressed'),
  queued('Queued'),
  deferred('Deferred'),
  sending('Sending'),
  retrying('Retrying'),
  sent('Sent'),
  failed('Failed'),
  expired('Expired'),
  deadLettered('DeadLettered'),
  cancelled('Cancelled'),
  opened('Opened'),
  dismissed('Dismissed'),
  unknown('Unknown');

  const DeliveryEventType(this.wire);

  @override
  final String wire;

  static DeliveryEventType parse(final String raw) => WireEnums.parse(values, raw, unknown);
}
