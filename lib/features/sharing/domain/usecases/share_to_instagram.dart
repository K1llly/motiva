import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/share_content.dart';
import '../repositories/share_repository.dart';

class ShareToInstagram implements UseCase<void, ShareContent> {
  final ShareRepository repository;

  ShareToInstagram(this.repository);

  @override
  Future<Either<Failure, void>> call(ShareContent params) async {
    return await repository.shareToInstagram(params);
  }
}
