import 'package:fpdart/fpdart.dart';
import '../models/notification_payload.dart';

final class InitialNotificationStore {
  Option<NotificationPayload> payload = const None();

  void set(final NotificationPayload value) => payload = payload.alt(() => some(value));

  Option<NotificationPayload> take() {
    final Option<NotificationPayload> taken = payload;
    payload = const None();
    return taken;
  }
}
