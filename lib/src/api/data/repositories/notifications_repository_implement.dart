import '../../../core/kits/data_kit.dart';
import '../../domain/entities/device_auth.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../data_sources/remote/notifications_remote_data_source.dart';

final class NotificationsRepositoryImplement implements NotificationsRepository {
  const NotificationsRepositoryImplement({required this.remote, required this.logger});

  final NotificationsRemoteDataSource remote;

  final KitLogger logger;

  @override
  Future<Either<ServiceFailure, bool>> reportEvent(
    final DeviceAuth device,
    final String notificationId,
    final DeliveryEventEntity event,
  ) => RepositoryGuard.guard(logger, () => remote.reportEvent(device, notificationId, event), 'REPORT_EVENT_ERROR');
}
