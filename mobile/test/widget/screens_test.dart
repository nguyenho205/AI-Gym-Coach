import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ai_coach_gym/core/routing/app_router.dart';
import 'package:ai_coach_gym/core/storage/local_storage_service.dart';
import 'package:ai_coach_gym/core/storage/secure_storage_service.dart';
import 'package:ai_coach_gym/core/theme/theme_provider.dart';
import 'package:ai_coach_gym/features/analysis/data/repositories/mock_analysis_repository.dart';
import 'package:ai_coach_gym/features/analysis/presentation/controllers/analysis_provider.dart';
import 'package:ai_coach_gym/features/analysis/presentation/screens/processing_screen.dart';
import 'package:ai_coach_gym/features/analysis/presentation/screens/result_screen.dart';
import 'package:ai_coach_gym/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:ai_coach_gym/features/auth/presentation/controllers/auth_provider.dart';
import 'package:ai_coach_gym/features/auth/presentation/screens/login_screen.dart';
import 'package:ai_coach_gym/features/auth/presentation/screens/register_screen.dart';
import 'package:ai_coach_gym/features/exercise/data/models/exercise_model.dart';
import 'package:ai_coach_gym/features/exercise/presentation/exercise_selection_screen.dart';
import 'package:ai_coach_gym/features/history/presentation/controllers/history_provider.dart';
import 'package:ai_coach_gym/features/history/presentation/history_screen.dart';
import 'package:ai_coach_gym/features/home/presentation/home_screen.dart';
import 'package:ai_coach_gym/features/profile/presentation/profile_screen.dart';
import 'package:ai_coach_gym/features/video/data/models/video_model.dart';
import 'package:ai_coach_gym/features/video/presentation/video_preview_screen.dart';
import 'package:ai_coach_gym/features/video/presentation/video_selection_screen.dart';

Widget _buildTestableWidget({
  required Widget child,
  AuthProvider? authProvider,
  AnalysisProvider? analysisProvider,
  HistoryProvider? historyProvider,
}) {
  final secureStorage = SecureStorageService(isInMemory: true);
  final localStorage = LocalStorageService(isInMemory: true);
  final authRepo = MockAuthRepository(
    secureStorage: secureStorage,
    localStorage: localStorage,
    simulatedDelay: false,
  );
  final analysisRepo = MockAnalysisRepository(simulatedDelay: false);

  return MultiProvider(
    providers: [
      Provider<LocalStorageService>.value(value: localStorage),
      ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
      ChangeNotifierProvider<AuthProvider>(create: (_) => authProvider ?? AuthProvider(authRepository: authRepo)),
      ChangeNotifierProvider<AnalysisProvider>(create: (_) => analysisProvider ?? AnalysisProvider(analysisRepository: analysisRepo)),
      ChangeNotifierProvider<HistoryProvider>(create: (_) => historyProvider ?? HistoryProvider(analysisRepository: analysisRepo)),
    ],
    child: MaterialApp(
      home: child,
      onGenerateRoute: AppRouter.onGenerateRoute,
    ),
  );
}

void main() {
  testWidgets('LoginScreen renders inputs and submit button', (tester) async {
    await tester.pumpWidget(_buildTestableWidget(child: const LoginScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byKey(const Key('login_email_input')), findsOneWidget);
    expect(find.byKey(const Key('login_password_input')), findsOneWidget);
    expect(find.byKey(const Key('login_submit_button')), findsOneWidget);
  });

  testWidgets('RegisterScreen renders registration fields', (tester) async {
    await tester.pumpWidget(_buildTestableWidget(child: const RegisterScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Join AI Coach Gym'), findsOneWidget);
    expect(find.byKey(const Key('register_name_input')), findsOneWidget);
    expect(find.byKey(const Key('register_email_input')), findsOneWidget);
    expect(find.byKey(const Key('register_password_input')), findsOneWidget);
    expect(find.byKey(const Key('register_confirm_password_input')), findsOneWidget);
    expect(find.byKey(const Key('register_submit_button')), findsOneWidget);
  });

  testWidgets('HomeScreen renders greeting and Analyze CTA', (tester) async {
    await tester.pumpWidget(_buildTestableWidget(child: const HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('HELLO, ATHLETE'), findsOneWidget);
    expect(find.byKey(const Key('home_analyze_cta_button')), findsOneWidget);
    expect(find.text('Supported Exercises'), findsOneWidget);
  });

  testWidgets('ExerciseSelectionScreen displays supported exercises', (tester) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_buildTestableWidget(child: const ExerciseSelectionScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Squat'), findsOneWidget);
    expect(find.text('Push-up'), findsOneWidget);
    expect(find.text('Bicep Curl'), findsOneWidget);
  });

  testWidgets('VideoSelectionScreen displays video capture choices', (tester) async {
    final analysisRepo = MockAnalysisRepository(simulatedDelay: false);
    final analysisProvider = AnalysisProvider(analysisRepository: analysisRepo);
    analysisProvider.selectExercise(ExerciseModel.supportedExercises.first);

    await tester.pumpWidget(
      _buildTestableWidget(
        child: const VideoSelectionScreen(),
        analysisProvider: analysisProvider,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('record_camera_card')), findsOneWidget);
    expect(find.byKey(const Key('select_gallery_card')), findsOneWidget);
    expect(find.byKey(const Key('select_sample_video_card')), findsOneWidget);
  });

  testWidgets('VideoPreviewScreen displays clip metadata', (tester) async {
    final analysisRepo = MockAnalysisRepository(simulatedDelay: false);
    final analysisProvider = AnalysisProvider(analysisRepository: analysisRepo);

    analysisProvider.selectExercise(ExerciseModel.supportedExercises.first);
    analysisProvider.setVideo(VideoModel(
      path: 'sample_squat.mp4',
      fileName: 'sample_squat.mp4',
      fileSizeBytes: 15 * 1024 * 1024,
      durationSeconds: 25,
      exerciseType: 'squat',
      selectedAt: DateTime.now(),
    ));

    await tester.pumpWidget(
      _buildTestableWidget(
        child: const VideoPreviewScreen(),
        analysisProvider: analysisProvider,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Review Video'), findsOneWidget);
    expect(find.text('sample_squat.mp4'), findsOneWidget);
    expect(find.byKey(const Key('start_analysis_button')), findsOneWidget);
  });

  testWidgets('ProcessingScreen displays stages', (tester) async {
    final analysisRepo = MockAnalysisRepository(simulatedDelay: false);
    final analysisProvider = AnalysisProvider(analysisRepository: analysisRepo);
    analysisProvider.selectExercise(ExerciseModel.supportedExercises.first);
    analysisProvider.setVideo(VideoModel(
      path: 'sample_squat.mp4',
      fileName: 'sample_squat.mp4',
      fileSizeBytes: 1024,
      durationSeconds: 20,
      exerciseType: 'squat',
      selectedAt: DateTime.now(),
    ));

    await tester.pumpWidget(
      _buildTestableWidget(
        child: const ProcessingScreen(),
        analysisProvider: analysisProvider,
      ),
    );

    // Initial pump (stages visible)
    await tester.pump();
    expect(find.text('BIOMECHANICAL ANALYSIS'), findsOneWidget);
    expect(find.text('Cancel Processing'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('ResultScreen displays score and technique feedback', (tester) async {
    final analysisRepo = MockAnalysisRepository(simulatedDelay: false);
    final analysisProvider = AnalysisProvider(analysisRepository: analysisRepo);

    analysisProvider.selectExercise(ExerciseModel.supportedExercises.first);
    analysisProvider.setVideo(VideoModel(
      path: 'sample.mp4',
      fileName: 'sample.mp4',
      fileSizeBytes: 1024,
      durationSeconds: 20,
      exerciseType: 'squat',
      selectedAt: DateTime.now(),
    ));

    // Perform analysis to populate result
    await analysisProvider.startAnalysis();

    await tester.pumpWidget(
      _buildTestableWidget(
        child: const ResultScreen(),
        analysisProvider: analysisProvider,
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Biomechanical Metrics'), findsOneWidget);
    expect(find.byKey(const Key('result_done_button')), findsOneWidget);
    expect(find.byKey(const Key('result_analyze_another_button')), findsOneWidget);
  });

  testWidgets('HistoryScreen renders list and filter options', (tester) async {
    await tester.pumpWidget(_buildTestableWidget(child: const HistoryScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Workout History'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Squat'), findsAtLeastNWidgets(1));
  });

  testWidgets('ProfileScreen displays athlete details and actions', (tester) async {
    await tester.pumpWidget(_buildTestableWidget(child: const ProfileScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Athlete Profile'), findsOneWidget);
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);
  });
}
