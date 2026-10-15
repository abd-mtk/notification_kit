import '../../../core/kits/domain_kit.dart';
import '../entities/device_auth.dart';
import '../entities/preferences.dart';

abstract class PreferencesRepository {
  Future<Either<ServiceFailure, PreferencesEntity>> getPreferences(final DeviceAuth device);

  Future<Either<ServiceFailure, UpdatedPreferencesEntity>> updatePreferences(
    final DeviceAuth device,
    final List<CategoryChoiceEntity> choices,
  );

  Future<Either<ServiceFailure, PreferencesEntity>> setQuietHours(
    final DeviceAuth device,
    final QuietHoursEntity quietHours,
  );

  Future<Either<ServiceFailure, PreferencesEntity>> clearQuietHours(final DeviceAuth device);
}
