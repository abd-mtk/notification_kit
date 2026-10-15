import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fpdart/fpdart.dart';

import '../models/push_config.dart';
import 'notification_channel.dart';
import 'notification_image.dart';

final class NotificationDetailsFactory {
  const NotificationDetailsFactory(this.config);

  final PushConfig config;

  String get groupKey => '${config.channelId}.group';

  ChannelSpec get defaultChannel => ChannelSpec.fromConfig(config);

  NotificationDetails message({
    required final String title,
    required final String body,
    final Option<NotificationImage> image = const None(),
    final Option<String> attachmentPath = const None(),
    final Option<ChannelSpec> channel = const None(),
  }) {
    final Option<ByteArrayAndroidBitmap> bitmap = image.map((final NotificationImage value) => value.androidBitmap);
    final ChannelSpec target = channel.getOrElse(() => defaultChannel);
    return NotificationDetails(
      android: AndroidNotificationDetails(
        target.id,
        target.name,
        channelDescription: target.description,
        importance: target.importance,
        priority: Priority.max,
        styleInformation: bitmap.match<StyleInformation>(
          () => BigTextStyleInformation(body),
          (final ByteArrayAndroidBitmap picture) =>
              BigPictureStyleInformation(picture, contentTitle: title, summaryText: body, hideExpandedLargeIcon: true),
        ),
        largeIcon: bitmap.toNullable(),
        playSound: true,
        enableVibration: true,
        autoCancel: true,
        icon: config.notificationIcon,
        groupKey: config.groupNotifications ? groupKey : null,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBanner: true,
        presentList: true,
        presentBadge: true,
        presentSound: true,
        threadIdentifier: channel.map((final ChannelSpec value) => value.id).toNullable(),
        attachments: attachmentPath.match(
          () => const <DarwinNotificationAttachment>[],
          (final String path) => <DarwinNotificationAttachment>[DarwinNotificationAttachment(path)],
        ),
      ),
    );
  }

  NotificationDetails summary(final int count) => NotificationDetails(
    android: AndroidNotificationDetails(
      config.channelId,
      config.channelName,
      channelDescription: config.channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      groupKey: groupKey,
      setAsGroupSummary: true,
      styleInformation: InboxStyleInformation(<String>[
        config.groupSummary(count),
      ], summaryText: config.groupSummary(count)),
      autoCancel: false,
    ),
  );
}
