import 'package:flutter_test/flutter_test.dart';
import 'package:signalplus/signalplus.dart';
import '../support/api_harness.dart';

void main() {
  test('the signed-in user topics are listed', () async {
    final ApiHarness harness = ApiHarness();
    harness.on('GET /sdk/v1/installations/i-1/recipient/topics', StubResponse.data(fixture('topics')));

    expect(rightOf(await harness.client.topics.recipientTopics(ApiHarness.device)), <String>['city-baghdad', 'news']);
  });

  test('subscribe and unsubscribe both answer the topics the user now follows', () async {
    final ApiHarness harness = ApiHarness();
    harness.on('PUT /sdk/v1/installations/i-1/recipient/topics/news', StubResponse.data(fixture('topics')));
    harness.on(
      'DELETE /sdk/v1/installations/i-1/recipient/topics/news',
      StubResponse.data(<String, dynamic>{
        'Topics': <String>['city-baghdad'],
      }),
    );

    expect(rightOf(await harness.client.topics.subscribe(ApiHarness.device, 'news')), contains('news'));
    expect(rightOf(await harness.client.topics.unsubscribe(ApiHarness.device, 'news')), <String>['city-baghdad']);
  });

  test('a topic the dashboard never created answers TopicNotFound', () async {
    final ApiHarness harness = ApiHarness();
    harness.on(
      'PUT /sdk/v1/installations/i-1/recipient/topics/aaa1',
      StubResponse.failure(404, <String>['TopicNotFound']),
    );

    final ServiceFailure failure = leftOf(await harness.client.topics.subscribe(ApiHarness.device, 'aaa1'));

    expect(failure.statusCode, 404);
    expect(failure.hasCode(ServiceErrorCodes.topicNotFound), isTrue);
  });

  test('the defined topics are listed without a device', () async {
    final ApiHarness harness = ApiHarness();
    harness.on('GET /sdk/v1/topics', StubResponse.data(fixture('topics')));

    expect(rightOf(await harness.client.topics.availableTopics()), <String>['city-baghdad', 'news']);
    expect(harness.last.url.toString(), 'https://sdk.test/sdk/v1/topics');
  });
}
