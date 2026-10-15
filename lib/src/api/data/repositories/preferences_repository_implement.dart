import '../../../core/kits/data_kit.dart';
import '../../domain/entities/device_auth.dart';
import '../../domain/entities/preferences.dart';
import '../../domain/repositories/preferences_repository.dart';
import '../data_sources/remote/preferences_remote_data_source.dart';

final class PreferencesRepositoryImplement implements PreferencesRepository {
  const PreferencesRepositoryImplement({required this.remote, required this.logger});

  final PreferencesRemoteDataSource remote;

  final KitLogger logger;

  @override
  Future<Either<ServiceFailure, PreferencesEntity>> getPreferences(final DeviceAuth device) =>
      RepositoryGuard.guard(logger, () => remote.getPreferences(device), 'GET_PREFERENCES_ERROR');

  @override
  Future<Either<ServiceFailure, UpdatedPreferencesEntity>> updatePreferences(
    final DeviceAuth device,
    final List<CategoryChoiceEntity> choices,
  ) => RepositoryGuard.guard(logger, () => remote.updatePreferences(device, choices), 'UPDATE_PREFERENCES_ERROR');

  @override
  Future<Either<ServiceFailure, PreferencesEntity>> setQuietHours(
    final DeviceAuth device,
    final QuietHoursEntity quietHours,
  ) => RepositoryGuard.guard(logger, () => remote.setQuietHours(device, quietHours), 'SET_QUIET_HOURS_ERROR');

  @override
  Future<Either<ServiceFailure, PreferencesEntity>> clearQuietHours(final DeviceAuth device) =>
      RepositoryGuard.guard(logger, () => remote.clearQuietHours(device), 'CLEAR_QUIET_HOURS_ERROR');
}
