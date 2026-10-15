import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signalplus/signalplus.dart';
import 'package:signalplus/src/push/notification/notification_permission.dart';

import '../support/push_fakes.dart';

void main() {
  late FakeMessaging fcm;
  late List<PushPermission> events;
  late NotificationPermissionService service;

  setUp(() {
    fcm = FakeMessaging();
    events = <PushPermission>[];
    service = NotificationPermissionService(
      messaging: fcm,
      events: eventsWith(onPermission: events.add),
      logger: silentLogger,
    );
  });

  test('concurrent requests share one dialog and the same result', () async {
    final Future<PushPermission> first = service.requestPermission();
    final Future<PushPermission> second = service.requestPermission();
    fcm.permission.complete(AuthorizationStatus.authorized);

    expect(await first, PushPermission.granted);
    expect(await second, PushPermission.granted);
    expect(fcm.permissionRequests, 1);
    expect(events, <PushPermission>[PushPermission.granted]);
  });

  test('a new request after the previous one finished asks again', () async {
    fcm.permission.complete(AuthorizationStatus.denied);
    expect(await service.requestPermission(), PushPermission.denied);

    fcm.permission = Completer<AuthorizationStatus>()..complete(AuthorizationStatus.provisional);
    expect(await service.requestPermission(), PushPermission.provisional);

    expect(fcm.permissionRequests, 2);
    expect(events, <PushPermission>[PushPermission.denied, PushPermission.provisional]);
  });

  test('the status reads the current settings without asking', () async {
    fcm.status = AuthorizationStatus.notDetermined;

    expect(await service.status(), PushPermission.notDetermined);
    expect(fcm.permissionRequests, 0);
  });
}
