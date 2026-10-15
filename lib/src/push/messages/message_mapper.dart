import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fpdart/fpdart.dart';

import '../models/notification_payload.dart';
import 'extensions.dart';
import 'message_keys.dart';
import 'notification_content.dart';

export 'extensions.dart';
export 'message_keys.dart';
export 'notification_content.dart';

abstract final class MessageMapper {
  static NotificationContent content(final RemoteMessage message, {required final String appName}) {
    final Option<RemoteNotification> block = message.notificationBlock;
    return NotificationContent(
      id: notificationId(message),
      title: (message.isDataOnly
              ? message.dataTitle
              : block.flatMap((final RemoteNotification value) => Option.fromNullable(value.title)))
          .getOrElse(() => appName),
      body: (message.isDataOnly
              ? message.dataBody
              : block.flatMap((final RemoteNotification value) => Option.fromNullable(value.body)))
          .getOrElse(() => ''),
      data: message.data,
      imageUrl: message.imageUrl,
      channelId: message.androidChannelId
          .alt(() => message.data.textAt(MessageKeys.channelId))
          .alt(() => message.data.nonEmptyTextAt(MessageKeys.category)),
    );
  }

  static NotificationPayload remote(final RemoteMessage message, {required final String appName}) {
    final Option<RemoteNotification> block = message.notificationBlock;
    return NotificationPayload.fromMap(
      message.data,
      defaultTitle: block
          .flatMap((final RemoteNotification value) => Option.fromNullable(value.title))
          .getOrElse(() => appName),
      defaultBody: block
          .flatMap((final RemoteNotification value) => Option.fromNullable(value.body))
          .getOrElse(() => ''),
    );
  }

  static NotificationPayload local(final Option<String> raw, {required final String defaultTitle}) =>
      decodeObject(raw).match(
        () => NotificationPayload(title: defaultTitle, body: '', data: const <String, dynamic>{}, rawPayload: raw),
        (final Map<String, dynamic> data) => NotificationPayload.fromMap(data, defaultTitle: defaultTitle),
      );

  static int notificationId(final RemoteMessage message) =>
      Option.fromNullable(message.messageId).match(() => DateTime.now().millisecondsSinceEpoch & 0x7fffffff, stableId);

  static int stableId(final String key) {
    int hash = 0x811c9dc5;
    for (final int unit in key.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0xffffffff;
    }
    final int id = hash & 0x7fffffff;
    return id == summaryNotificationId ? 1 : id;
  }

  static Option<Map<String, dynamic>> decodeObject(final Option<String> raw) =>
      raw.filter((final String text) => text.isNotEmpty).flatMap((final String text) {
        try {
          return switch (jsonDecode(text)) {
            final Map<String, dynamic> data => some(data),
            _ => const None(),
          };
        } on FormatException {
          return const None();
        }
      });
}
