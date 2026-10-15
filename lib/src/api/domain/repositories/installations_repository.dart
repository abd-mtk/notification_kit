import '../../../core/kits/domain_kit.dart';
import '../entities/device_auth.dart';
import '../entities/installation.dart';

abstract class InstallationsRepository {
  Future<Either<ServiceFailure, SdkInstallationEntity>> register(
    final DeviceAuth device,
    final RegisterInstallationEntity request,
  );

  Future<Either<ServiceFailure, SdkInstallationEntity>> login(
    final DeviceAuth device, {
    required final String externalId,
  });

  Future<Either<ServiceFailure, SdkInstallationEntity>> logout(final DeviceAuth device);
}
