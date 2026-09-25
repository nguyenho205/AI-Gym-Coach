import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ai_coach_gym/core/routing/app_router.dart';
import 'package:ai_coach_gym/core/storage/local_storage_service.dart';
import 'package:ai_coach_gym/core/storage/secure_storage_service.dart';
import 'package:ai_coach_gym/core/theme/theme_provider.dart';
import 'package:ai_coach_gym/features/analysis/data/repositories/mock_analysis_repository.dart';
import 'package:ai_coach_gym/features/analysis/presentation/controllers/analysis_provider.dart';
import 'package:ai_coach_gym/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:ai_coach_gym/features/auth/presentation/controllers/auth_provider.dart';
import 'package:ai_coach_gym/features/history/presentation/controllers/history_provider.dart';

import 'package:ai_coach_gym/features/auth/presentation/screens/login_screen.dart';

void main() {
  testWidgets('Full End-to-End User Flow Integration Test', (tester) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 1. Setup DI & Repositories with simulatedDelay: false for instant deterministic testing
    final secureStorage = SecureStorageService(isInMemory: true);
    final localStorage = LocalStorageService(isInMemory: true);
    final authRepo = MockAuthRepository(
      secureStorage: secureStorage,
      localStorage: localStorage,
      simulatedDelay: false,
    );
    final analysisRepo = MockAnalysisRepository(simulatedDelay: false);

    final authProvider = AuthProvider(authRepository: authRepo);
    final analysisProvider = AnalysisProvider(analysisRepository: analysisRepo);
    final historyProvider = HistoryProvider(analysisRepository: analysisRepo);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<LocalStorageService>.value(value: localStorage),
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<AnalysisProvider>.value(value: analysisProvider),
          ChangeNotifierProvider<HistoryProvider>.value(value: historyProvider),
        ],
        child: MaterialApp(
          home: const LoginScreen(),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 2. Step 1: Login Screen
    expect(find.text('Welcome back'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('login_email_input')), 'alex@gym.com');
    await tester.enterText(find.byKey(const Key('login_password_input')), 'password123');
    await tester.tap(find.byKey(const Key('login_submit_button')));

    // Wait for login transition to Home
    await tester.pumpAndSettle();
    expect(find.text('HELLO, ATHLETE'), findsOneWidget);

    // 3. Step 2: Tap Primary "Analyze Exercise" CTA on Home
    final analyzeCta = find.byKey(const Key('home_analyze_cta_button'));
    expect(analyzeCta, findsOneWidget);
    await tester.tap(analyzeCta);
    await tester.pumpAndSettle();

    // 4. Step 3: Exercise Selection Screen
    expect(find.text('What are you training today?'), findsOneWidget);
    expect(find.text('Squat'), findsOneWidget);

    // Tap "Continue with Squat"
    final continueExerciseBtn = find.byKey(const Key('exercise_continue_button'));
    expect(continueExerciseBtn, findsOneWidget);
    await tester.tap(continueExerciseBtn);
    await tester.pumpAndSettle();

    // 5. Step 4: Video Selection Screen
    expect(find.text('Record or Select\nExercise Video'), findsOneWidget);

    // Tap "Use Test Workout Clip" card
    final sampleVideoCard = find.byKey(const Key('select_sample_video_card'));
    expect(sampleVideoCard, findsOneWidget);
    await tester.tap(sampleVideoCard);
    await tester.pumpAndSettle();

    // 6. Step 5: Video Preview Screen
    expect(find.text('Review Video'), findsOneWidget);
    expect(find.text('Clip Metadata'), findsOneWidget);

    // Tap "Start AI Analysis" button
    final startAnalysisBtn = find.byKey(const Key('start_analysis_button'));
    expect(startAnalysisBtn, findsOneWidget);
    await tester.tap(startAnalysisBtn);

    // 7. Step 6 & 7: Processing & Result Screen
    // Since simulatedDelay is false, startAnalysis completes immediately and replaces route with Result
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('Biomechanical Metrics'), findsOneWidget);
    expect(find.byKey(const Key('result_done_button')), findsOneWidget);
    expect(find.byKey(const Key('result_analyze_another_button')), findsOneWidget);

    // Tap Done to return to Home Dashboard
    await tester.tap(find.byKey(const Key('result_done_button')));
    await tester.pumpAndSettle();
    expect(find.text('HELLO, ATHLETE'), findsOneWidget);
  });
}
