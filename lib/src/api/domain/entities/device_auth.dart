import '../../../core/kits/domain_kit.dart';

final class DeviceAuth extends Equatable {
  const DeviceAuth({required this.installationId});

  final String installationId;

  @override
  List<Object> get props => <Object>[installationId];
}
