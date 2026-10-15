import '../../../../core/kits/data_kit.dart';
import '../../../client/api_http_client.dart';
import '../../../domain/entities/notification.dart';
import '../../models/notification.dart';

final class NotificationsRemoteDataSource {
  const NotificationsRemoteDataSource(this.http);

  final ApiHttpClient http;

  Future<bool> reportEvent(
    final DeviceAuth device,
    final String notificationId,
    final DeliveryEventEntity event,
  ) async {
    final ApiResponse response = await http.send(
      ApiRequest.device(HttpVerb.post, device, <String>[
        'notifications',
        notificationId,
        'events',
      ], body: Some(DeliveryEventModel.toJson(event))),
    );
    return JsonReader.boolean(response.object, 'Applied');
  }
}
