import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/domain/auth_validators.dart';

void main() {
  group('validatePassword', () {
    test('requires a special character', () {
      expect(
        validatePassword('Password1'),
        'Include at least one special character',
      );
    });

    test('accepts a password with the required character mix', () {
      expect(validatePassword('Password1!'), isNull);
    });
  });

  group('buildPasswordRequirements', () {
    test('includes the special character requirement', () {
      final requirements = buildPasswordRequirements('Password1');
      expect(requirements, hasLength(5));
      expect(
        requirements.last.description,
        'Contains one special character',
      );
      expect(requirements.last.isMet, isFalse);
    });
  });
}
