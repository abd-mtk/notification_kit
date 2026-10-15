import '../../../core/kits/domain_kit.dart';
import 'enums.dart';

final class DeliveryEventEntity extends Equatable {
  const DeliveryEventEntity({required this.type, this.at = const None()});

  final DeliveryEventType type;

  final Option<DateTime> at;

  @override
  List<Object> get props => <Object>[type, at];
}
