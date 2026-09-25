import 'package:flutter_test/flutter_test.dart';
import 'package:ai_coach_gym/core/utils/formatters.dart';

void main() {
  group('Formatters Unit Tests', () {
    test('formatDuration formats seconds to MM:SS', () {
      expect(Formatters.formatDuration(0), '00:00');
      expect(Formatters.formatDuration(45), '00:45');
      expect(Formatters.formatDuration(65), '01:05');
      expect(Formatters.formatDuration(120), '02:00');
    });

    test('formatBytes formats file sizes correctly', () {
      expect(Formatters.formatBytes(500), '500 B');
      expect(Formatters.formatBytes(2048), '2.0 KB');
      expect(Formatters.formatBytes(15 * 1024 * 1024), '15.0 MB');
    });

    test('scoreLabel categorizes form correctly', () {
      expect(Formatters.scoreLabel(95), 'Flawless Form');
      expect(Formatters.scoreLabel(85), 'Good Form');
      expect(Formatters.scoreLabel(75), 'Fair Form');
      expect(Formatters.scoreLabel(65), 'Needs Practice');
      expect(Formatters.scoreLabel(50), 'Improper Form');
    });
  });
}
