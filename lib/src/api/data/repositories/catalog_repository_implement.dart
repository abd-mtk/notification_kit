import '../../../core/kits/data_kit.dart';
import '../../domain/entities/catalog.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../data_sources/remote/catalog_remote_data_source.dart';

final class CatalogRepositoryImplement implements CatalogRepository {
  const CatalogRepositoryImplement({required this.remote, required this.logger});

  final CatalogRemoteDataSource remote;

  final KitLogger logger;

  @override
  Future<Either<ServiceFailure, List<CategoryEntity>>> listCategories() =>
      RepositoryGuard.guard(logger, remote.listCategories, 'LIST_CATEGORIES_ERROR');
}
