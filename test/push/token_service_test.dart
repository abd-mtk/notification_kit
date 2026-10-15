import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signalplus/signalplus.dart';
import 'package:signalplus/src/push/firebase/token_service.dart';
import 'package:signalplus/src/push/models/push_events.dart';

import '../support/push_fakes.dart';

void main() {
  late FakeMessaging messaging;
  late List<String> tokens;
  late PushEvents events;
  late TokenService service;

  setUp(() {
    messaging = FakeMessaging();
    tokens = <String>[];
    events = eventsWith(onToken: tokens.add);
    service = TokenService(
      messaging: messaging,
      events: events,
      logger: silentLogger,
      apnsAttempts: 3,
      apnsRetryDelay: Duration.zero,
    );
  });

  tearDown(() async {
    debugDefaultTargetPlatformOverride = null;
    await service.dispose();
  });

  test('a fetched token is published and remembered', () async {
    expect(await service.getToken(), 'token-1234567890');

    expect(tokens, <String>['token-1234567890']);
    expect(events.latestToken, const Some('token-1234567890'));
  });

  test('the same token is never published twice', () async {
    service.listenForRefresh();
    await service.getToken();
    messaging.refreshController.add('token-1234567890');
    await Future<void>.delayed(Duration.zero);

    expect(tokens, <String>['token-1234567890']);
  });

  test('a refreshed token is published', () async {
    service.listenForRefresh();
    await service.getToken();
    messaging.refreshController.add('token-new-0000000');
    await Future<void>.delayed(Duration.zero);

    expect(tokens, <String>['token-1234567890', 'token-new-0000000']);
  });

  test('refresh swallows failures and answers nothing', () async {
    messaging.getTokenError = Exception('offline');

    expect(await service.refresh(), const None());
    expect(tokens, isEmpty);
  });

  test('on iOS the token waits for APNs', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    messaging.apnsTokens = <String?>[null, null, 'apns'];

    expect(await service.getToken(), 'token-1234567890');
    expect(messaging.apnsCalls, 3);
  });

  test('on iOS without APNs the fetch is skipped with a typed error', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    messaging.apnsTokens = <String?>[null];

    await expectLater(service.getToken(), throwsA(isA<Exception>()));
    expect(messaging.apnsCalls, 3);
    expect(messaging.getTokenCalls, 0);
  });

  test('Android does not wait for APNs', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    await service.getToken();

    expect(messaging.apnsCalls, 0);
  });

  test('after deleting, the same token is published again', () async {
    await service.getToken();
    await service.deleteToken();
    messaging.token = 'token-1234567890';
    await service.getToken();

    expect(tokens, <String>['token-1234567890', 'token-1234567890']);
  });
}
