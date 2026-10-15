import '../../../core/kits/data_kit.dart';
import '../../domain/entities/device_auth.dart';
import '../../domain/repositories/topics_repository.dart';
import '../data_sources/remote/topics_remote_data_source.dart';

final class TopicsRepositoryImplement implements TopicsRepository {
  const TopicsRepositoryImplement({required this.remote, required this.logger});

  final TopicsRemoteDataSource remote;

  final KitLogger logger;

  @override
  Future<Either<ServiceFailure, List<String>>> availableTopics() =>
      RepositoryGuard.guard(logger, remote.available, 'LIST_TOPICS_ERROR');

  @override
  Future<Either<ServiceFailure, List<String>>> recipientTopics(final DeviceAuth device) =>
      RepositoryGuard.guard(logger, () => remote.recipientTopics(device), 'GET_TOPICS_ERROR');

  @override
  Future<Either<ServiceFailure, List<String>>> subscribe(final DeviceAuth device, final String topic) =>
      RepositoryGuard.guard(logger, () => remote.subscribe(device, topic), 'SUBSCRIBE_TOPIC_ERROR');

  @override
  Future<Either<ServiceFailure, List<String>>> unsubscribe(final DeviceAuth device, final String topic) =>
      RepositoryGuard.guard(logger, () => remote.unsubscribe(device, topic), 'UNSUBSCRIBE_TOPIC_ERROR');
}
