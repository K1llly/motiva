import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/share_content.dart';
import '../repositories/share_repository.dart';

class ShareToWhatsApp implements UseCase<void, ShareContent> {
  final ShareRepository repository;

  ShareToWhatsApp(this.repository);

  @override
  Future<Either<Failure, void>> call(ShareContent params) async {
    return await repository.shareToWhatsApp(params);
  }
}
