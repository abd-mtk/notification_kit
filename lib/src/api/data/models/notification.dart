import '../../../core/kits/data_kit.dart';
import '../../domain/entities/notification.dart';

abstract final class DeliveryEventModel {
  static JsonMap toJson(final DeliveryEventEntity event) => <String, dynamic>{
    'Type': event.type.wire,
    ...JsonWriter.compact(<String, Option<Object>>{'At': event.at.map(JsonWriter.date)}),
  };
}
