import 'package:fpdart/fpdart.dart';

import '../../api/domain/entities/enums.dart';
import '../../core/utils/json_reader.dart';
import '../../core/utils/logger.dart';

final class PushConfig {
  const PushConfig({
    this.notificationIcon = '@mipmap/ic_launcher',
    this.enableLogs = true,
    this.requestPermissionOnStartup = true,
    this.showForegroundNotification = true,
    this.clearNotificationsOnLaunch = false,
    this.groupNotifications = false,
    this.groupSummary = countOnly,
    this.showNotificationImages = true,
    this.logger = const None(),
  }) : appName = '',
       channelName = '',
       channelDescription = '';

  const PushConfig.resolved({
    required this.appName,
    required this.channelName,
    required this.channelDescription,
    this.notificationIcon = '@mipmap/ic_launcher',
    this.enableLogs = true,
    this.requestPermissionOnStartup = true,
    this.showForegroundNotification = true,
    this.clearNotificationsOnLaunch = false,
    this.groupNotifications = false,
    this.groupSummary = countOnly,
    this.showNotificationImages = true,
    this.logger = const None(),
  });

  factory PushConfig.fromJson(final JsonMap json) => PushConfig.resolved(
    appName: JsonReader.string(json, 'AppName'),
    channelName: JsonReader.string(json, 'ChannelName'),
    channelDescription: JsonReader.string(json, 'ChannelDescription'),
    notificationIcon: JsonReader.string(json, 'Icon'),
    enableLogs: JsonReader.boolean(json, 'Logs'),
    groupNotifications: JsonReader.boolean(json, 'Group'),
    showNotificationImages: JsonReader.boolean(json, 'Images'),
  );

  static const String defaultChannelId = 'signalplus_default';

  static const Map<ServiceLocale, ({String name, String description})> defaultChannelTexts =
      <ServiceLocale, ({String name, String description})>{
        ServiceLocale.ar: (name: 'الإشعارات العامة', description: 'إشعارات التطبيق العامة'),
        ServiceLocale.en: (name: 'General notifications', description: 'General app notifications'),
      };

  final String appName;

  final String channelName;

  final String channelDescription;

  final String notificationIcon;

  final bool enableLogs;

  final bool requestPermissionOnStartup;

  final bool showForegroundNotification;

  final bool clearNotificationsOnLaunch;

  final bool groupNotifications;

  final String Function(int count) groupSummary;

  final bool showNotificationImages;

  final Option<LogSink> logger;

  String get channelId => defaultChannelId;

  KitLogger get kitLogger =>
      logger.match(() => KitLogger.debug(enabled: enableLogs), (final LogSink sink) => KitLogger(sink: sink));

  PushConfig display({required final String appName, required final ServiceLocale locale}) {
    final ({String name, String description}) texts =
        defaultChannelTexts[locale] ?? defaultChannelTexts[ServiceLocale.en]!;
    return PushConfig.resolved(
      appName: appName,
      channelName: texts.name,
      channelDescription: texts.description,
      notificationIcon: notificationIcon,
      enableLogs: enableLogs,
      requestPermissionOnStartup: requestPermissionOnStartup,
      showForegroundNotification: showForegroundNotification,
      clearNotificationsOnLaunch: clearNotificationsOnLaunch,
      groupNotifications: groupNotifications,
      groupSummary: groupSummary,
      showNotificationImages: showNotificationImages,
      logger: logger,
    );
  }

  PushConfig localized(final ServiceLocale locale) => display(appName: appName, locale: locale);

  JsonMap toJson() => <String, dynamic>{
    'AppName': appName,
    'ChannelName': channelName,
    'ChannelDescription': channelDescription,
    'Icon': notificationIcon,
    'Logs': enableLogs,
    'Group': groupNotifications,
    'Images': showNotificationImages,
  };

  static String countOnly(final int count) => '$count';
}
