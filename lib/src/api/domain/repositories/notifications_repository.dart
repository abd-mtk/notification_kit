import '../../../core/kits/domain_kit.dart';
import '../entities/device_auth.dart';
import '../entities/notification.dart';

abstract class NotificationsRepository {
  Future<Either<ServiceFailure, bool>> reportEvent(
    final DeviceAuth device,
    final String notificationId,
    final DeliveryEventEntity event,
  );
}
