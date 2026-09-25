import 'package:flutter_test/flutter_test.dart';
import 'package:ai_coach_gym/core/utils/validators.dart';

void main() {
  group('Validators Unit Tests', () {
    test('requiredField validation', () {
      expect(Validators.requiredField(null, 'Name'), 'Name is required');
      expect(Validators.requiredField('   ', 'Name'), 'Name is required');
      expect(Validators.requiredField('John', 'Name'), isNull);
    });

    test('email validation', () {
      expect(Validators.email(null), 'Email address is required');
      expect(Validators.email(''), 'Email address is required');
      expect(Validators.email('invalid-email'), 'Please enter a valid email address');
      expect(Validators.email('test@'), 'Please enter a valid email address');
      expect(Validators.email('athlete@example.com'), isNull);
    });

    test('password validation', () {
      expect(Validators.password(null), 'Password is required');
      expect(Validators.password('12345'), 'Password must be at least 6 characters long');
      expect(Validators.password('123456'), isNull);
    });

    test('confirmPassword validation', () {
      expect(Validators.confirmPassword(null, 'secret'), 'Please confirm your password');
      expect(Validators.confirmPassword('wrong', 'secret'), 'Passwords do not match');
      expect(Validators.confirmPassword('secret', 'secret'), isNull);
    });
  });
}
