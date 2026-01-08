import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/share_content.dart';
import '../../domain/repositories/share_repository.dart';
import '../services/share_service.dart';

class ShareRepositoryImpl implements ShareRepository {
  final ShareService shareService;

  ShareRepositoryImpl({required this.shareService});

  @override
  Future<Either<Failure, void>> shareToInstagram(ShareContent content) async {
    try {
      await shareService.shareForInstagram(content.text);
      return const Right(null);
    } catch (e) {
      return Left(ShareFailure('Failed to share to Instagram: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> shareToTwitter(ShareContent content) async {
    try {
      await shareService.shareToTwitter(content.text);
      return const Right(null);
    } catch (e) {
      return Left(ShareFailure('Failed to share to Twitter: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> shareToWhatsApp(ShareContent content) async {
    try {
      await shareService.shareToWhatsApp(content.text);
      return const Right(null);
    } catch (e) {
      return Left(ShareFailure('Failed to share to WhatsApp: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> shareGeneric(ShareContent content) async {
    try {
      await shareService.shareText(content.text);
      return const Right(null);
    } catch (e) {
      return Left(ShareFailure('Failed to share: ${e.toString()}'));
    }
  }
}
