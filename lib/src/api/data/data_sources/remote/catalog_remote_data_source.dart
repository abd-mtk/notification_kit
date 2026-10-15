import '../../../client/api_http_client.dart';
import '../../../domain/entities/catalog.dart';
import '../../models/catalog.dart';

final class CatalogRemoteDataSource {
  const CatalogRemoteDataSource(this.http);

  final ApiHttpClient http;

  Future<List<CategoryEntity>> listCategories() async {
    final ApiResponse response = await http.send(const ApiRequest(HttpVerb.get, <String>['categories']));
    return response.list.map(CategoryModel.parse).toList(growable: false);
  }
}
