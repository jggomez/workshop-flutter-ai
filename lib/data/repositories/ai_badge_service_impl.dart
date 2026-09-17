import 'dart:typed_data';
import '../../domain/entities/ai_badge_result.dart';
import '../../domain/repositories/i_ai_badge_service.dart';
import '../datasources/ai_badge_remote_datasource.dart';

/// Implementation of [IAiBadgeService] delegating to [AiBadgeRemoteDataSource].
class AiBadgeServiceImpl implements IAiBadgeService {
  final AiBadgeRemoteDataSource _dataSource;

  AiBadgeServiceImpl([AiBadgeRemoteDataSource? dataSource])
      : _dataSource = dataSource ?? AiBadgeRemoteDataSource();

  @override
  Future<AiBadgeResult> generateDashBadge({
    required Uint8List photoBytes,
    required String attendeeName,
  }) async {
    return await _dataSource.generateBadge(
      photoBytes: photoBytes,
      attendeeName: attendeeName,
    );
  }
}
