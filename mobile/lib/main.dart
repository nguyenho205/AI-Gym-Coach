import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/constants/app_constants.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_provider.dart';
import 'core/network/api_client.dart';
import 'core/routing/app_router.dart';
import 'core/routing/app_routes.dart';
import 'core/storage/local_storage_service.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/analysis/data/repositories/analysis_repository.dart';
import 'features/analysis/data/repositories/mock_analysis_repository.dart';
import 'features/analysis/data/repositories/remote_analysis_repository.dart';
import 'features/analysis/presentation/controllers/analysis_provider.dart';
import 'features/exercise/data/repositories/exercise_repository.dart';
import 'features/exercise/presentation/controllers/exercise_provider.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/data/repositories/mock_auth_repository.dart';
import 'features/auth/data/repositories/remote_auth_repository.dart';
import 'features/auth/presentation/controllers/auth_provider.dart';
import 'features/history/presentation/controllers/history_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Core Services
  final secureStorage = SecureStorageService();
  final localStorage = LocalStorageService();
  final initialBaseUrl = await localStorage.getBaseUrl();

  final apiClient = ApiClient(
    secureStorage: secureStorage,
    baseUrl: initialBaseUrl,
  );

  // Repository Layer
  // By default in dev without running backend, we can allow graceful mock fallback
  // or instantiate remote repositories.
  const bool useMock = AppConstants.allowDemoRepository;

  final AuthRepository authRepository = useMock
      ? MockAuthRepository(secureStorage: secureStorage, localStorage: localStorage)
      : RemoteAuthRepository(apiClient: apiClient, secureStorage: secureStorage, localStorage: localStorage);

  final AnalysisRepository analysisRepository = useMock
      ? MockAnalysisRepository()
      : RemoteAnalysisRepository(apiClient: apiClient);

  final ExerciseRepository exerciseRepository = ExerciseRepository(apiClient: apiClient);

  runApp(
    MultiProvider(
      providers: [
        // Core Singletons
        Provider<ISecureStorageService>.value(value: secureStorage),
        Provider<LocalStorageService>.value(value: localStorage),
        Provider<ApiClient>.value(value: apiClient),
        Provider<AuthRepository>.value(value: authRepository),
        Provider<AnalysisRepository>.value(value: analysisRepository),
        Provider<ExerciseRepository>.value(value: exerciseRepository),

        // Reactive State Providers
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authRepository: authRepository),
        ),
        ChangeNotifierProvider<AnalysisProvider>(
          create: (_) => AnalysisProvider(analysisRepository: analysisRepository),
        ),
        ChangeNotifierProvider<HistoryProvider>(
          create: (_) => HistoryProvider(analysisRepository: analysisRepository),
        ),
        ChangeNotifierProvider<ExerciseProvider>(
          create: (_) => ExerciseProvider(repository: exerciseRepository),
        ),
        ChangeNotifierProvider<LocaleProvider>(
          create: (_) => LocaleProvider(storage: localStorage),
        ),
      ],
      child: const AiCoachGymApp(),
    ),
  );
}

class AiCoachGymApp extends StatelessWidget {
  const AiCoachGymApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      locale: localeProvider.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
