import '../../../../core/kits/data_kit.dart';
import '../../../client/api_http_client.dart';
import '../../../domain/entities/installation.dart';
import '../../models/installation.dart';

final class InstallationsRemoteDataSource {
  const InstallationsRemoteDataSource(this.http);

  final ApiHttpClient http;

  Future<SdkInstallationEntity> register(final DeviceAuth device, final RegisterInstallationEntity request) async {
    final ApiResponse response = await http.send(
      ApiRequest.device(HttpVerb.put, device, const <String>[], body: Some(InstallationModel.toJson(request))),
    );
    return InstallationModel.installationFromJson(response.object);
  }

  Future<SdkInstallationEntity> login(final DeviceAuth device, final String externalId) async {
    final ApiResponse response = await http.send(
      ApiRequest.device(HttpVerb.post, device, const <String>[
        'login',
      ], body: Some(InstallationModel.loginToJson(externalId))),
    );
    return InstallationModel.installationFromJson(response.object);
  }

  Future<SdkInstallationEntity> logout(final DeviceAuth device) async {
    final ApiResponse response = await http.send(ApiRequest.device(HttpVerb.post, device, const <String>['logout']));
    return InstallationModel.installationFromJson(response.object);
  }
}
