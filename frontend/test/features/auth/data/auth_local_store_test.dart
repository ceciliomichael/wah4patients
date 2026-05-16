import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/data/auth_local_store.dart';
import 'package:frontend/features/auth/domain/models/auth_api_models.dart';

AuthSessionData _buildSession({
  required DateTime savedAt,
  int expiresIn = 3600,
}) {
  return AuthSessionData(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    expiresIn: expiresIn,
    tokenType: 'bearer',
    userId: 'user-id',
    userEmail: 'patient@example.com',
    profile: UserProfileSummary.empty(),
    savedAt: savedAt,
  );
}

void main() {
  group('AuthSessionData', () {
    test('reports a session as expired only at or after expiry', () {
      final savedAt = DateTime.utc(2025, 1, 1, 12);
      final session = _buildSession(savedAt: savedAt);

      expect(
        session.isExpiredAt(DateTime.utc(2025, 1, 1, 12, 59, 59)),
        isFalse,
      );
      expect(session.isExpiredAt(DateTime.utc(2025, 1, 1, 13)), isTrue);
    });

    test('flags a session as expiring soon before the buffer window ends', () {
      final savedAt = DateTime.utc(2025, 1, 1, 12);
      final session = _buildSession(savedAt: savedAt);

      expect(
        session.isExpiringSoon(now: DateTime.utc(2025, 1, 1, 12, 54, 59)),
        isFalse,
      );
      expect(
        session.isExpiringSoon(now: DateTime.utc(2025, 1, 1, 12, 55)),
        isTrue,
      );
    });
  });
}
