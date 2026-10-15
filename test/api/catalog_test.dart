import 'package:flutter_test/flutter_test.dart';
import 'package:signalplus/signalplus.dart';
import '../support/api_harness.dart';

void main() {
  test('categories carry one localized name, the Android channel id and the lane', () async {
    final ApiHarness harness = ApiHarness();
    harness.on('GET /sdk/v1/categories', StubResponse.data(fixture('categories')));

    final List<CategoryEntity> categories = rightOf(await harness.client.catalog.listCategories());

    expect(categories.first.name, 'الطلبات');
    expect(categories.first.channelId, 'orders');
    expect(categories.first.lane, Lane.critical);
    expect(categories.last.androidChannelId, const None());
    expect(categories.last.channelId, 'Promotions');
    expect(categories.last.description, const None());
  });
}
