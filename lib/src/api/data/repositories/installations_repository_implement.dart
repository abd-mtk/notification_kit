import '../../../core/kits/data_kit.dart';
import '../../domain/entities/device_auth.dart';
import '../../domain/entities/installation.dart';
import '../../domain/repositories/installations_repository.dart';
import '../data_sources/remote/installations_remote_data_source.dart';

final class InstallationsRepositoryImplement implements InstallationsRepository {
  const InstallationsRepositoryImplement({required this.remote, required this.logger});

  final InstallationsRemoteDataSource remote;

  final KitLogger logger;

  @override
  Future<Either<ServiceFailure, SdkInstallationEntity>> register(
    final DeviceAuth device,
    final RegisterInstallationEntity request,
  ) => RepositoryGuard.guard(logger, () => remote.register(device, request), 'REGISTER_INSTALLATION_ERROR');

  @override
  Future<Either<ServiceFailure, SdkInstallationEntity>> login(
    final DeviceAuth device, {
    required final String externalId,
  }) => RepositoryGuard.guard(logger, () => remote.login(device, externalId), 'LOGIN_ERROR');

  @override
  Future<Either<ServiceFailure, SdkInstallationEntity>> logout(final DeviceAuth device) =>
      RepositoryGuard.guard(logger, () => remote.logout(device), 'LOGOUT_ERROR');
}
