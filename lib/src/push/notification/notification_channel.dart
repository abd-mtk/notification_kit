import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fpdart/fpdart.dart';

import '../../api/domain/entities/enums.dart';
import '../models/push_config.dart';

final class ChannelSpec {
  const ChannelSpec({
    required this.id,
    required this.name,
    required this.description,
    this.importance = Importance.max,
  });

  factory ChannelSpec.fromConfig(final PushConfig config) =>
      ChannelSpec(id: config.channelId, name: config.channelName, description: config.channelDescription);

  final String id;

  final String name;

  final String description;

  final Importance importance;

  static Importance importanceFor(final Lane lane) => switch (lane) {
    Lane.critical => Importance.max,
    Lane.transactional => Importance.high,
    Lane.bulk => Importance.defaultImportance,
  };
}

abstract final class AndroidChannels {
  static Future<void> create(final FlutterLocalNotificationsPlugin plugin, final List<ChannelSpec> channels) async {
    final Option<AndroidFlutterLocalNotificationsPlugin> android = Option.fromNullable(
      plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>(),
    );
    await android.match(() async {}, (final AndroidFlutterLocalNotificationsPlugin platform) async {
      for (final ChannelSpec channel in channels) {
        await platform.createNotificationChannel(
          AndroidNotificationChannel(
            channel.id,
            channel.name,
            description: channel.description,
            importance: channel.importance,
            enableLights: true,
            enableVibration: true,
            showBadge: true,
          ),
        );
      }
    });
  }
}
