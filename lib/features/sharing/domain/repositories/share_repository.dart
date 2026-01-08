import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/share_content.dart';

abstract class ShareRepository {
  Future<Either<Failure, void>> shareToInstagram(ShareContent content);
  Future<Either<Failure, void>> shareToTwitter(ShareContent content);
  Future<Either<Failure, void>> shareToWhatsApp(ShareContent content);
  Future<Either<Failure, void>> shareGeneric(ShareContent content);
}
