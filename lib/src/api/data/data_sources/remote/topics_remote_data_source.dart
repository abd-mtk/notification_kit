import '../../../../core/kits/data_kit.dart';
import '../../../client/api_http_client.dart';

final class TopicsRemoteDataSource {
  const TopicsRemoteDataSource(this.http);

  final ApiHttpClient http;

  Future<List<String>> available() => topics(const ApiRequest(HttpVerb.get, <String>['topics']));

  Future<List<String>> recipientTopics(final DeviceAuth device) =>
      topics(ApiRequest.device(HttpVerb.get, device, const <String>['recipient', 'topics']));

  Future<List<String>> subscribe(final DeviceAuth device, final String topic) =>
      topics(ApiRequest.device(HttpVerb.put, device, <String>['recipient', 'topics', topic]));

  Future<List<String>> unsubscribe(final DeviceAuth device, final String topic) =>
      topics(ApiRequest.device(HttpVerb.delete, device, <String>['recipient', 'topics', topic]));

  Future<List<String>> topics(final ApiRequest request) async =>
      JsonReader.strings((await http.send(request)).object, 'Topics');
}
