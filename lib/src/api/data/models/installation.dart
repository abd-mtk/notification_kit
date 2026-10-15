import '../../../core/kits/data_kit.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/installation.dart';

abstract final class InstallationModel {
  static JsonMap toJson(final RegisterInstallationEntity entity) => <String, dynamic>{
    'Platform': entity.platform.wire,
    'Token': entity.token,
    'PushPermission': entity.pushPermission.wire,
    'AppVersion': entity.appVersion,
    'BuildNumber': entity.buildNumber,
    'Locale': entity.locale,
    'TimeZone': entity.timeZone,
    ...JsonWriter.compact(<String, Option<Object>>{'OsVersion': entity.osVersion, 'DeviceModel': entity.deviceModel}),
  };

  static SdkInstallationEntity installationFromJson(final JsonMap json) => SdkInstallationEntity(
    installationId: JsonReader.string(json, 'InstallationId'),
    externalId: JsonReader.optString(json, 'ExternalId'),
    tokenStatus: TokenStatus.parse(JsonReader.string(json, 'TokenStatus')),
    pushPermission: PushPermission.parse(JsonReader.string(json, 'PushPermission')),
  );

  static JsonMap loginToJson(final String externalId) => <String, dynamic>{'ExternalId': externalId};
}
