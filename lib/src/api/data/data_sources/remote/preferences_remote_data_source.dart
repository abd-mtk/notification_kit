import '../../../../core/kits/data_kit.dart';
import '../../../client/api_http_client.dart';
import '../../../domain/entities/preferences.dart';
import '../../models/preferences.dart';

final class PreferencesRemoteDataSource {
  const PreferencesRemoteDataSource(this.http);

  final ApiHttpClient http;

  static const List<String> preferences = <String>['recipient', 'preferences'];
  static const List<String> quietHours = <String>['recipient', 'quiet-hours'];

  Future<PreferencesEntity> getPreferences(final DeviceAuth device) async {
    final ApiResponse response = await http.send(ApiRequest.device(HttpVerb.get, device, preferences));
    return PreferencesModel.fromJson(response.object);
  }

  Future<UpdatedPreferencesEntity> updatePreferences(
    final DeviceAuth device,
    final List<CategoryChoiceEntity> choices,
  ) async {
    final ApiResponse response = await http.send(
      ApiRequest.device(HttpVerb.put, device, preferences, body: Some(PreferencesModel.choicesToJson(choices))),
    );
    return PreferencesModel.updatedFromJson(response.object);
  }

  Future<PreferencesEntity> setQuietHours(final DeviceAuth device, final QuietHoursEntity entity) async {
    final ApiResponse response = await http.send(
      ApiRequest.device(HttpVerb.put, device, quietHours, body: Some(PreferencesModel.quietHoursToJson(entity))),
    );
    return PreferencesModel.fromJson(response.object);
  }

  Future<PreferencesEntity> clearQuietHours(final DeviceAuth device) async {
    final ApiResponse response = await http.send(ApiRequest.device(HttpVerb.delete, device, quietHours));
    return PreferencesModel.fromJson(response.object);
  }
}
