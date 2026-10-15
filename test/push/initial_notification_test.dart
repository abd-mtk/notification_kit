import 'package:flutter_test/flutter_test.dart';
import 'package:signalplus/signalplus.dart';
import 'package:signalplus/src/push/notification/initial_notification.dart';

void main() {
  const NotificationPayload payload = NotificationPayload(title: 'T', body: 'B', data: <String, dynamic>{});

  test('the stored payload is returned only once', () {
    final InitialNotificationStore store = InitialNotificationStore()..set(payload);

    expect(store.take(), const Some(payload));
    expect(store.take(), const None());
  });

  test('the first launch notification is kept', () {
    const NotificationPayload second = NotificationPayload(title: 'Second', body: '', data: <String, dynamic>{});
    final InitialNotificationStore store =
        InitialNotificationStore()
          ..set(payload)
          ..set(second);

    expect(store.take(), const Some(payload));
  });
}
