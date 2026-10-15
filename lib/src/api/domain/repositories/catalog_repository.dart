import '../../../core/kits/domain_kit.dart';
import '../entities/catalog.dart';

abstract class CatalogRepository {
  Future<Either<ServiceFailure, List<CategoryEntity>>> listCategories();
}
