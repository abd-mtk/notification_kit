import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fpdart/fpdart.dart';

import '../../api/domain/entities/enums.dart';
import '../../core/utils/logger.dart';
import '../messages/extensions.dart';
import '../models/push_events.dart';

final class NotificationPermissionService {
  NotificationPermissionService({required this.messaging, required this.events, required final KitLogger logger})
    : log = logger.tagged('Permission');

  final FirebaseMessaging messaging;

  final PushEvents events;

  final KitLogger log;

  Option<Future<PushPermission>> pendingRequest = const None();

  Future<PushPermission> requestPermission() => pendingRequest.getOrElse(() {
    final Future<PushPermission> request = ask().whenComplete(() => pendingRequest = const None());
    pendingRequest = some(request);
    return request;
  });

  Future<PushPermission> status() async =>
      (await messaging.getNotificationSettings()).authorizationStatus.pushPermission;

  Future<PushPermission> ask() async {
    try {
      final NotificationSettings settings = await messaging.requestPermission(alert: true, badge: true, sound: true);
      final PushPermission permission = settings.authorizationStatus.pushPermission;
      log.info('Permission status: ${permission.wire}');
      events.permission(permission);
      return permission;
    } on Object catch (error, stackTrace) {
      log.error('Permission request failed', error, stackTrace);
      events.permission(PushPermission.notDetermined);
      return PushPermission.notDetermined;
    }
  }
}
