import '../../domain/models/auth_api_models.dart';

class SecuritySettingsStatusCacheService {
  SecuritySettingsStatusCacheService._();

  static String? _userId;
  static SecuritySettingsStatusResult? _status;

  static SecuritySettingsStatusResult? getCachedStatus({required String userId}) {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      return null;
    }

    if (_userId != normalizedUserId) {
      return null;
    }

    return _status;
  }

  static void cacheStatus({
    required String userId,
    required SecuritySettingsStatusResult status,
  }) {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      return;
    }

    _userId = normalizedUserId;
    _status = status;
  }

  static void clear() {
    _userId = null;
    _status = null;
  }
}
