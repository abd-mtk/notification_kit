import '../../../core/kits/domain_kit.dart';
import 'enums.dart';

final class RegisterInstallationEntity extends Equatable {
  const RegisterInstallationEntity({
    required this.platform,
    required this.token,
    required this.pushPermission,
    required this.appVersion,
    required this.buildNumber,
    required this.locale,
    required this.timeZone,
    this.osVersion = const None(),
    this.deviceModel = const None(),
  });

  final DevicePlatform platform;

  final String token;

  final PushPermission pushPermission;

  final String appVersion;

  final String buildNumber;

  final Option<String> osVersion;

  final Option<String> deviceModel;

  final String locale;

  final String timeZone;

  @override
  List<Object> get props => <Object>[
    platform,
    token,
    pushPermission,
    appVersion,
    buildNumber,
    osVersion,
    deviceModel,
    locale,
    timeZone,
  ];
}

final class SdkInstallationEntity extends Equatable {
  const SdkInstallationEntity({
    required this.installationId,
    required this.tokenStatus,
    required this.pushPermission,
    this.externalId = const None(),
  });

  final String installationId;

  final Option<String> externalId;

  final TokenStatus tokenStatus;

  final PushPermission pushPermission;

  @override
  List<Object> get props => <Object>[installationId, externalId, tokenStatus, pushPermission];
}
