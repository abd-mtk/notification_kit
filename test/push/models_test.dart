import 'package:flutter_test/flutter_test.dart';
import 'package:signalplus/signalplus.dart';

void main() {
  group('PushConfig', () {
    test('optional values have defaults', () {
      const PushConfig config = PushConfig.resolved(
        appName: 'Test App',
        channelName: 'Test Notifications',
        channelDescription: 'D',
      );

      expect(config.channelDescription, 'D');
      expect(config.notificationIcon, '@mipmap/ic_launcher');
      expect(config.enableLogs, isTrue);
      expect(config.requestPermissionOnStartup, isTrue);
      expect(config.showForegroundNotification, isTrue);
      expect(config.clearNotificationsOnLaunch, isFalse);
      expect(config.groupNotifications, isFalse);
      expect(config.groupSummary(3), '3');
    });

    test('a custom log sink receives the log lines', () {
      final List<String> lines = <String>[];
      final PushConfig config = PushConfig.resolved(
        appName: 'A',
        channelName: 'C',
        channelDescription: 'D',
        logger: Some((final String tag, final String message) => lines.add('$tag:$message')),
      );

      config.kitLogger.info('hello');

      expect(lines, <String>['SignalPlus:hello']);
    });

    test('the group summary text can be localized', () {
      final PushConfig config = PushConfig.resolved(
        appName: 'A',
        channelName: 'C',
        channelDescription: 'D',
        groupSummary: (final int count) => '$count إشعارات جديدة',
      );

      expect(config.groupSummary(2), '2 إشعارات جديدة');
    });
  });

  group('NotificationPayload', () {
    test('fromMap extracts title, body and data', () {
      final NotificationPayload payload = NotificationPayload.fromMap(<String, dynamic>{
        'title': 'Test Title',
        'body': 'Test Body',
        'key1': 'value1',
        'key2': 123,
      });

      expect(payload.title, 'Test Title');
      expect(payload.body, 'Test Body');
      expect(payload.data['key2'], 123);
      expect(payload.rawPayload, const None());
    });

    test('the default title is used when there is none', () {
      final NotificationPayload payload = NotificationPayload.fromMap(<String, dynamic>{
        'body': 'Body only',
      }, defaultTitle: 'Fallback App');

      expect(payload.title, 'Fallback App');
      expect(payload.body, 'Body only');
    });

    test('a nested notification map is read', () {
      final NotificationPayload payload = NotificationPayload.fromMap(<String, dynamic>{
        'notification': <String, String>{'title': 'Nested', 'body': 'Nested body'},
      });

      expect(payload.title, 'Nested');
      expect(payload.body, 'Nested body');
    });

    test('non string titles and non map notifications are ignored', () {
      expect(NotificationPayload.fromMap(<String, dynamic>{'title': 42}, defaultTitle: 'F').title, 'F');
      expect(NotificationPayload.fromMap(<String, dynamic>{'notification': 'oops'}, defaultTitle: 'F').body, '');
    });

    test('an empty body falls back to the default body', () {
      expect(NotificationPayload.fromMap(<String, dynamic>{'body': ''}, defaultBody: 'From FCM').body, 'From FCM');
    });

    test('the service NotifyId and Category are read from data', () {
      final NotificationPayload payload = NotificationPayload.fromMap(<String, dynamic>{
        'NotifyId': 'ntf_01',
        'Category': 'Orders',
      });

      expect(payload.notifyId, const Some('ntf_01'));
      expect(payload.category, const Some('Orders'));
      expect(NotificationPayload.fromMap(<String, dynamic>{'NotifyId': ''}).notifyId, const None());
    });
  });
}
