import '../../../core/kits/domain_kit.dart';
import '../entities/device_auth.dart';

abstract class TopicsRepository {
  Future<Either<ServiceFailure, List<String>>> availableTopics();

  Future<Either<ServiceFailure, List<String>>> recipientTopics(final DeviceAuth device);

  Future<Either<ServiceFailure, List<String>>> subscribe(final DeviceAuth device, final String topic);

  Future<Either<ServiceFailure, List<String>>> unsubscribe(final DeviceAuth device, final String topic);
}
