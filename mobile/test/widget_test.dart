import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ai_coach_gym/core/storage/local_storage_service.dart';
import 'package:ai_coach_gym/core/storage/secure_storage_service.dart';
import 'package:ai_coach_gym/core/theme/theme_provider.dart';
import 'package:ai_coach_gym/features/analysis/data/repositories/mock_analysis_repository.dart';
import 'package:ai_coach_gym/features/analysis/presentation/controllers/analysis_provider.dart';
import 'package:ai_coach_gym/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:ai_coach_gym/features/auth/presentation/controllers/auth_provider.dart';
import 'package:ai_coach_gym/features/history/presentation/controllers/history_provider.dart';
import 'package:ai_coach_gym/main.dart';

void main() {
  testWidgets('App root smoke test', (WidgetTester tester) async {
    final secureStorage = SecureStorageService();
    final localStorage = LocalStorageService();
    final authRepo = MockAuthRepository(secureStorage: secureStorage, localStorage: localStorage);
    final analysisRepo = MockAnalysisRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<LocalStorageService>.value(value: localStorage),
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
          ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider(authRepository: authRepo)),
          ChangeNotifierProvider<AnalysisProvider>(create: (_) => AnalysisProvider(analysisRepository: analysisRepo)),
          ChangeNotifierProvider<HistoryProvider>(create: (_) => HistoryProvider(analysisRepository: analysisRepo)),
        ],
        child: const AiCoachGymApp(),
      ),
    );

    // Initial pump for splash screen
    await tester.pump();
    expect(find.byType(AiCoachGymApp), findsOneWidget);
    expect(find.text('AI Gym Coach'), findsOneWidget);

    // Advance time beyond splash delay
    await tester.pump(const Duration(seconds: 2));
  });
}
