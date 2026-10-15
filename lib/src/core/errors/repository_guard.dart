import 'package:fpdart/fpdart.dart';

import '../utils/logger.dart';
import 'failures.dart';
import 'handler.dart';

abstract final class RepositoryGuard {
  static Future<Either<ServiceFailure, T>> guard<T>(
    final KitLogger logger,
    final Future<T> Function() run,
    final String operation,
  ) async {
    try {
      return Right(await run());
    } on Object catch (error, stackTrace) {
      final ServiceFailure failure = FailureHandler.from(error, operation: operation);
      logger.error(operation, failure, error is Exception ? StackTrace.empty : stackTrace);
      return Left(failure);
    }
  }
}
