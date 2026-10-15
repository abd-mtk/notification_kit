import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signalplus/signalplus.dart';
import 'package:signalplus/src/push/messages/message_mapper.dart';

void main() {
  group('local payloads', () {
    test('a JSON object payload becomes title and data', () {
      final NotificationPayload payload = MessageMapper.local(
        const Some('{"title":"T","route":"/orders"}'),
        defaultTitle: 'App',
      );

      expect(payload.title, 'T');
      expect(payload.data['route'], '/orders');
      expect(payload.rawPayload, const None());
    });

    test('a non JSON payload is kept raw', () {
      final NotificationPayload payload = MessageMapper.local(const Some('order:42'), defaultTitle: 'App');

      expect(payload.title, 'App');
      expect(payload.data, isEmpty);
      expect(payload.rawPayload, const Some('order:42'));
    });

    test('a JSON payload that is not an object is kept raw', () {
      expect(MessageMapper.local(const Some('[1,2]'), defaultTitle: 'App').rawPayload, const Some('[1,2]'));
    });

    test('a missing payload falls back to the app name', () {
      final NotificationPayload payload = MessageMapper.local(const None(), defaultTitle: 'App');

      expect(payload.title, 'App');
      expect(payload.rawPayload, const None());
    });
  });

  group('stable ids', () {
    test('the same key gives the same positive id', () {
      final int id = MessageMapper.stableId('0:1700000000000000%abc');

      expect(id, MessageMapper.stableId('0:1700000000000000%abc'));
      expect(id, greaterThan(0));
      expect(id, lessThanOrEqualTo(0x7fffffff));
    });

    test('different keys give different ids', () {
      expect(MessageMapper.stableId('a'), isNot(MessageMapper.stableId('b')));
    });

    test('a message id is stable', () {
      const RemoteMessage message = RemoteMessage(messageId: '0:123%abc');

      expect(MessageMapper.notificationId(message), MessageMapper.notificationId(message));
    });
  });

  group('needsLocalDisplay', () {
    const RemoteMessage dataOnly = RemoteMessage(data: <String, dynamic>{'title': 'T'});
    const RemoteMessage withNotification = RemoteMessage(notification: RemoteNotification(title: 'T'));

    tearDown(() => debugDefaultTargetPlatformOverride = null);

    test('data only messages are always shown by the package', () {
      for (final TargetPlatform platform in <TargetPlatform>[TargetPlatform.android, TargetPlatform.iOS]) {
        debugDefaultTargetPlatformOverride = platform;
        expect(dataOnly.needsLocalDisplay(foreground: true), isTrue);
        expect(dataOnly.needsLocalDisplay(foreground: false), isTrue);
      }
    });

    test('notification messages in the background are left to the OS', () {
      for (final TargetPlatform platform in <TargetPlatform>[TargetPlatform.android, TargetPlatform.iOS]) {
        debugDefaultTargetPlatformOverride = platform;
        expect(withNotification.needsLocalDisplay(foreground: false), isFalse);
      }
    });

    test('in the foreground Android shows locally and iOS does not', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(withNotification.needsLocalDisplay(foreground: true), isTrue);

      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(withNotification.needsLocalDisplay(foreground: true), isFalse);
    });
  });

  group('content', () {
    test('the notification block wins over data', () {
      const RemoteMessage message = RemoteMessage(
        notification: RemoteNotification(title: 'N', body: 'NB'),
        data: <String, dynamic>{'title': 'D', 'body': 'DB'},
      );

      final NotificationContent content = MessageMapper.content(message, appName: 'App');

      expect(content.title, 'N');
      expect(content.body, 'NB');
    });

    test('data only messages read title and body from data', () {
      final NotificationContent content = MessageMapper.content(
        const RemoteMessage(data: <String, dynamic>{'title': 'D', 'body': 'DB'}),
        appName: 'App',
      );

      expect(content.title, 'D');
      expect(content.body, 'DB');
    });

    test('non string values fall back to the app name', () {
      final NotificationContent content = MessageMapper.content(
        const RemoteMessage(data: <String, dynamic>{'title': 1}),
        appName: 'App',
      );

      expect(content.title, 'App');
      expect(content.body, '');
    });

    test('the channel comes from the android block, then channel_id, then the service Category', () {
      expect(
        MessageMapper.content(
          const RemoteMessage(
            notification: RemoteNotification(android: AndroidNotification(channelId: 'A')),
            data: <String, dynamic>{'Category': 'C'},
          ),
          appName: 'App',
        ).channelId,
        const Some('A'),
      );
      expect(
        MessageMapper.content(
          const RemoteMessage(data: <String, dynamic>{'channel_id': 'B', 'Category': 'C'}),
          appName: 'App',
        ).channelId,
        const Some('B'),
      );
      expect(
        MessageMapper.content(const RemoteMessage(data: <String, dynamic>{'Category': 'C'}), appName: 'App').channelId,
        const Some('C'),
      );
    });
  });

  group('imageUrl', () {
    test('android first, then apple, then data.image', () {
      const RemoteMessage message = RemoteMessage(
        notification: RemoteNotification(
          android: AndroidNotification(imageUrl: 'https://a.test/android.png'),
          apple: AppleNotification(imageUrl: 'https://a.test/apple.png'),
        ),
        data: <String, dynamic>{'image': 'https://a.test/data.png'},
      );

      expect(message.imageUrl, const Some('https://a.test/android.png'));
    });

    test('apple and data are fallbacks', () {
      const RemoteMessage apple = RemoteMessage(
        notification: RemoteNotification(apple: AppleNotification(imageUrl: 'https://a.test/apple.png')),
      );
      const RemoteMessage dataOnly = RemoteMessage(data: <String, dynamic>{'image': 'https://a.test/data.png'});

      expect(apple.imageUrl, const Some('https://a.test/apple.png'));
      expect(dataOnly.imageUrl, const Some('https://a.test/data.png'));
    });

    test('non string, empty and non http values are ignored', () {
      expect(const RemoteMessage(data: <String, dynamic>{'image': 42}).imageUrl, const None());
      expect(const RemoteMessage(data: <String, dynamic>{'image': ''}).imageUrl, const None());
      expect(const RemoteMessage(data: <String, dynamic>{'image': 'file:///etc/passwd'}).imageUrl, const None());
      expect(const RemoteMessage().imageUrl, const None());
    });
  });
}
