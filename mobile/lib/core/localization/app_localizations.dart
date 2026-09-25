import 'package:flutter/widgets.dart';

/// Supported language definitions
enum AppLanguage {
  english('en', 'English', 'English'),
  vietnamese('vi', 'Tiếng Việt', 'Vietnamese'),
  chinese('zh', '中文 (简体)', 'Chinese');

  final String code;
  final String displayName;
  final String englishName;

  const AppLanguage(this.code, this.displayName, this.englishName);

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.english,
    );
  }
}

/// Centralized localization dictionary for English, Vietnamese, and Chinese.
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('vi'),
    Locale('zh'),
  ];

  String get _code => locale.languageCode;

  // Translation dictionaries
  static final Map<String, Map<String, String>> _translations = {
    'en': {
      // General
      'appName': 'AI Gym Coach',
      'tagline': 'Smart Computer Vision Fitness Technique Analyzer',
      'save': 'Save',
      'cancel': 'Cancel',
      'continue': 'Continue',
      'loading': 'Loading...',
      'error': 'Error',
      'retry': 'Retry',
      'delete': 'Delete',
      'success': 'Success',
      'ready': 'READY',
      'notSet': 'Not set',
      'viewAll': 'View All',
      'noData': 'No data yet',

      // Navigation
      'navHome': 'Home',
      'navExercises': 'Exercises',
      'navHistory': 'History',
      'navProfile': 'Profile',
      'navSettings': 'Settings',

      // Auth
      'helloAthlete': 'HELLO, ATHLETE',
      'welcomeBack': 'Welcome back',
      'joinGym': 'Join AI Coach Gym',
      'loginTitle': 'Sign In to Your Account',
      'email': 'Email',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'fullName': 'Full Name',
      'signIn': 'Sign In',
      'signUp': 'Sign Up',
      'createAccount': 'Create Account',
      'noAccount': "Don't have an account? Sign up",
      'haveAccount': 'Already have an account? Sign in',
      'logout': 'Sign Out',
      'logoutConfirm': 'Are you sure you want to sign out?',

      // Home
      'heroBadge': 'Computer Vision Coach',
      'heroTitle': 'Perfect Your Form,\nPrevent Injury',
      'heroSubtitle': 'Upload a 60s video of your Squat, Push-up, or Bicep Curl for deep landmark posture analysis.',
      'analyzeExercise': 'Analyze Exercise',
      'averageForm': 'AVERAGE FORM',
      'repsEvaluated': 'REPS EVALUATED',
      'sessionsLogged': 'sessions logged',
      'supportedExercises': 'Supported Exercises',
      'recentActivity': 'Recent Activity',
      'noRecentActivity': 'No workout sessions analyzed yet. Start your first session!',
      'startFirstWorkout': 'Start Workout',

      // Exercise Selection
      'exerciseSelectionTitle': 'Select Exercise',
      'whatTrainingToday': 'What are you training today?',
      'exerciseSelectionSubtitle': 'Choose an exercise to start AI biomechanical analysis',
      'categoryAll': 'All',
      'categoryLegs': 'Legs',
      'categoryChest': 'Chest',
      'categoryArms': 'Arms',
      'techniqueFocus': 'Technique Focus',
      'startAnalysis': 'Start Analysis',

      // Video Selection & Recording
      'videoSelectionTitle': 'Upload Exercise Video',
      'chooseGallery': 'Choose from Gallery',
      'recordCamera': 'Record with Camera',
      'recordingGuidelines': 'Recording Guidelines',
      'guideline1': 'Ensure whole body is clearly visible in camera frame',
      'guideline2': 'Maintain bright lighting; avoid loose clothing concealing joints',
      'guideline3': 'Duration maximum 60 seconds and file size under 100 MB',
      'videoPreview': 'Video Preview',
      'changeVideo': 'Change Video',
      'submitForAnalysis': 'Submit for AI Analysis',

      // Processing
      'processingTitle': 'Analyzing Biomechanics',
      'processingSubtitle': 'Our MediaPipe and ST-GCN AI models are extracting landmarks, angles, and evaluating technique...',
      'stageExtracting': 'Extracting 33 pose landmarks...',
      'stageKinematics': 'Computing joint angles & kinematics...',
      'stageScoring': 'Evaluating biomechanical rules & technique...',
      'stageFinalizing': 'Finalizing comprehensive analysis report...',

      // Result
      'resultTitle': 'Analysis Report',
      'overallScore': 'Overall Technique Score',
      'repsCompleted': 'Reps Completed',
      'jointMetrics': 'Joint Metrics & ROM',
      'detectedErrors': 'Detected Faults',
      'noErrorsFound': 'Flawless form! No major biomechanical faults detected.',
      'coachingFeedback': 'Coaching Recommendations',
      'backToHome': 'Back to Home',
      'analyzedOn': 'Analyzed on',

      // History
      'historyTitle': 'Workout History',
      'historySubtitle': 'Track your technique progression over time',
      'noHistory': 'No exercise sessions found',
      'deleteConfirm': 'Are you sure you want to delete this session?',
      'itemDeleted': 'Session record deleted',

      // Profile
      'profileTitle': 'Athlete Profile',
      'editProfile': 'Edit Profile',
      'height': 'Height',
      'weight': 'Weight',
      'gender': 'Gender',
      'male': 'Male',
      'female': 'Female',
      'otherGender': 'Other',
      'athleteDetails': 'Athlete Details',
      'physicalMetricsHelp': 'Physical metrics calibrate camera perspective and joint angles for higher accuracy.',
      'profileUpdated': 'Profile updated successfully',

      // Settings
      'settingsTitle': 'Settings',
      'appearance': 'Appearance',
      'darkMode': 'Dark Theme',
      'lightMode': 'Light Theme',
      'language': 'Language',
      'selectLanguage': 'Select Language',
      'serverConfig': 'Server Connection',
      'serverUrl': 'API Server URL',
      'aboutApp': 'About AI Gym Coach',
      'version': 'Version',
    },
    'vi': {
      // General
      'appName': 'AI Gym Coach',
      'tagline': 'Hệ thống Phân tích Kỹ thuật Gym bằng Thị giác Máy tính',
      'save': 'Lưu',
      'cancel': 'Hủy',
      'continue': 'Tiếp tục',
      'loading': 'Đang tải...',
      'error': 'Lỗi',
      'retry': 'Thử lại',
      'delete': 'Xóa',
      'success': 'Thành công',
      'ready': 'SẴN SÀNG',
      'notSet': 'Chưa thiết lập',
      'viewAll': 'Xem tất cả',
      'noData': 'Chưa có dữ liệu',

      // Navigation
      'navHome': 'Trang chủ',
      'navExercises': 'Bài tập',
      'navHistory': 'Lịch sử',
      'navProfile': 'Cá nhân',
      'navSettings': 'Cài đặt',

      // Auth
      'helloAthlete': 'XIN CHÀO, VẬN ĐỘNG VIÊN',
      'welcomeBack': 'Chào mừng trở lại',
      'joinGym': 'Tham gia AI Gym Coach',
      'loginTitle': 'Đăng nhập vào tài khoản của bạn',
      'email': 'Email',
      'password': 'Mật khẩu',
      'confirmPassword': 'Xác nhận mật khẩu',
      'fullName': 'Họ và tên',
      'signIn': 'Đăng nhập',
      'signUp': 'Đăng ký',
      'createAccount': 'Tạo tài khoản',
      'noAccount': 'Chưa có tài khoản? Đăng ký ngay',
      'haveAccount': 'Đã có tài khoản? Đăng nhập',
      'logout': 'Đăng xuất',
      'logoutConfirm': 'Bạn có chắc chắn muốn đăng xuất không?',

      // Home
      'heroBadge': 'HLV Thị giác Máy tính',
      'heroTitle': 'Hoàn thiện tư thế,\nTránh chấn thương',
      'heroSubtitle': 'Tải video 60 giây bài tập Squat, Push-up hoặc Bicep Curl để phân tích tư thế khớp chi tiết.',
      'analyzeExercise': 'Phân tích bài tập',
      'averageForm': 'ĐIỂM TRUNG BÌNH',
      'repsEvaluated': 'REP ĐÃ ĐÁNH GIÁ',
      'sessionsLogged': 'buổi tập đã ghi',
      'supportedExercises': 'Bài tập hỗ trợ',
      'recentActivity': 'Hoạt động gần đây',
      'noRecentActivity': 'Chưa có buổi tập nào được phân tích. Hãy bắt đầu buổi tập đầu tiên!',
      'startFirstWorkout': 'Bắt đầu tập',

      // Exercise Selection
      'exerciseSelectionTitle': 'Chọn bài tập',
      'whatTrainingToday': 'Hôm nay bạn muốn tập gì?',
      'exerciseSelectionSubtitle': 'Chọn bài tập để bắt đầu phân tích cơ sinh học AI',
      'categoryAll': 'Tất cả',
      'categoryLegs': 'Chân',
      'categoryChest': 'Ngực',
      'categoryArms': 'Tay',
      'techniqueFocus': 'Trọng tâm kỹ thuật',
      'startAnalysis': 'Bắt đầu phân tích',

      // Video Selection & Recording
      'videoSelectionTitle': 'Tải lên video bài tập',
      'chooseGallery': 'Chọn từ Thư viện',
      'recordCamera': 'Quay bằng Camera',
      'recordingGuidelines': 'Hướng dẫn quay video',
      'guideline1': 'Đảm bảo toàn bộ cơ thể hiển thị rõ trong khung hình',
      'guideline2': 'Đủ ánh sáng; tránh mặc quần áo quá rộng che khuất khớp',
      'guideline3': 'Thời lượng tối đa 60 giây và kích thước dưới 100 MB',
      'videoPreview': 'Xem trước video',
      'changeVideo': 'Đổi video khác',
      'submitForAnalysis': 'Gửi phân tích AI',

      // Processing
      'processingTitle': 'Đang phân tích cơ sinh học',
      'processingSubtitle': 'Mô hình MediaPipe và ST-GCN đang trích xuất điểm khớp, góc chuyển động và chấm điểm...',
      'stageExtracting': 'Đang trích xuất 33 điểm mốc tư thế...',
      'stageKinematics': 'Đang tính toán động học và góc khớp...',
      'stageScoring': 'Đang đánh giá quy tắc cơ sinh học & tư thế...',
      'stageFinalizing': 'Đang hoàn tất báo cáo phân tích toàn diện...',

      // Result
      'resultTitle': 'Báo cáo phân tích',
      'overallScore': 'Điểm kỹ thuật tổng quan',
      'repsCompleted': 'Số Rep hoàn thành',
      'jointMetrics': 'Chỉ số góc khớp & ROM',
      'detectedErrors': 'Lỗi kỹ thuật phát hiện',
      'noErrorsFound': 'Tư thế hoàn hảo! Không phát hiện lỗi cơ sinh học nghiêm trọng nào.',
      'coachingFeedback': 'Lời khuyên từ Huấn luyện viên AI',
      'backToHome': 'Về trang chủ',
      'analyzedOn': 'Thời gian phân tích',

      // History
      'historyTitle': 'Lịch sử luyện tập',
      'historySubtitle': 'Theo dõi sự tiến bộ kỹ thuật qua từng buổi tập',
      'noHistory': 'Chưa có buổi tập nào được lưu',
      'deleteConfirm': 'Bạn có chắc muốn xóa bản ghi buổi tập này?',
      'itemDeleted': 'Đã xóa bản ghi buổi tập',

      // Profile
      'profileTitle': 'Hồ sơ vận động viên',
      'editProfile': 'Chỉnh sửa hồ sơ',
      'height': 'Chiều cao',
      'weight': 'Cân nặng',
      'gender': 'Giới tính',
      'male': 'Nam',
      'female': 'Nữ',
      'otherGender': 'Khác',
      'athleteDetails': 'Thông tin vận động viên',
      'physicalMetricsHelp': 'Chỉ số cơ thể giúp hiệu chuẩn góc camera và góc khớp chính xác hơn.',
      'profileUpdated': 'Cập nhật hồ sơ thành công',

      // Settings
      'settingsTitle': 'Cài đặt',
      'appearance': 'Giao diện',
      'darkMode': 'Chế độ tối',
      'lightMode': 'Chế độ sáng',
      'language': 'Ngôn ngữ',
      'selectLanguage': 'Chọn ngôn ngữ',
      'serverConfig': 'Kết nối máy chủ',
      'serverUrl': 'Địa chỉ máy chủ API',
      'aboutApp': 'Về AI Gym Coach',
      'version': 'Phiên bản',
    },
    'zh': {
      // General
      'appName': 'AI Gym Coach',
      'tagline': '基于计算机视觉的健身动作技术分析系统',
      'save': '保存',
      'cancel': '取消',
      'continue': '继续',
      'loading': '加载中...',
      'error': '错误',
      'retry': '重试',
      'delete': '删除',
      'success': '成功',
      'ready': '准备就绪',
      'notSet': '未设置',
      'viewAll': '查看全部',
      'noData': '暂无数据',

      // Navigation
      'navHome': '首页',
      'navExercises': '动作项目',
      'navHistory': '历史记录',
      'navProfile': '个人中心',
      'navSettings': '设置',

      // Auth
      'helloAthlete': '你好，运动员',
      'welcomeBack': '欢迎回来',
      'joinGym': '加入 AI Gym Coach',
      'loginTitle': '登录您的账户',
      'email': '电子邮箱',
      'password': '密码',
      'confirmPassword': '确认密码',
      'fullName': '全名',
      'signIn': '登录',
      'signUp': '注册',
      'createAccount': '创建账户',
      'noAccount': '还没有账户？立即注册',
      'haveAccount': '已有账户？立即登录',
      'logout': '退出登录',
      'logoutConfirm': '您确定要退出登录吗？',

      // Home
      'heroBadge': '计算机视觉私教',
      'heroTitle': '规范动作姿势，\n预防运动损伤',
      'heroSubtitle': '上传60秒内的深蹲、俯卧撑或弯举视频，进行深度人体关节姿态分析。',
      'analyzeExercise': '分析运动姿势',
      'averageForm': '平均动作评分',
      'repsEvaluated': '已评估动作次数',
      'sessionsLogged': '次训练记录',
      'supportedExercises': '支持的训练动作',
      'recentActivity': '最近动态',
      'noRecentActivity': '暂无动作分析记录。立即开始您的首次测试！',
      'startFirstWorkout': '开始训练',

      // Exercise Selection
      'exerciseSelectionTitle': '选择训练动作',
      'whatTrainingToday': '今天你想训练什么？',
      'exerciseSelectionSubtitle': '选择一个动作以启动AI生物力学分析',
      'categoryAll': '全部',
      'categoryLegs': '腿部',
      'categoryChest': '胸部',
      'categoryArms': '手臂',
      'techniqueFocus': '核心要点',
      'startAnalysis': '开始分析',

      // Video Selection & Recording
      'videoSelectionTitle': '上传训练视频',
      'chooseGallery': '从相册选择',
      'recordCamera': '使用相机录制',
      'recordingGuidelines': '视频拍摄指南',
      'guideline1': '确保整个身体在画面中清晰完整可见',
      'guideline2': '保持光线充足，避免过于宽松衣物遮挡关键关节',
      'guideline3': '视频最长60秒，文件大小不超过100 MB',
      'videoPreview': '视频预览',
      'changeVideo': '更换视频',
      'submitForAnalysis': '提交AI智能分析',

      // Processing
      'processingTitle': '正在进行生物力学分析',
      'processingSubtitle': 'MediaPipe与ST-GCN模型正在提取人体关键点、计算关节角度并评估动作...',
      'stageExtracting': '正在提取33个人体姿态关键点...',
      'stageKinematics': '正在计算关节角度与运动学参数...',
      'stageScoring': '正在进行动作技术规则与体态评分...',
      'stageFinalizing': '正在生成最终动作分析评估报告...',

      // Result
      'resultTitle': '动作分析评估报告',
      'overallScore': '综合动作技术评分',
      'repsCompleted': '完成动作次数',
      'jointMetrics': '关节角度与活动度(ROM)',
      'detectedErrors': '检测到的动作缺陷',
      'noErrorsFound': '动作姿势非常标准！未检测到明显生物力学缺陷。',
      'coachingFeedback': 'AI教练改进建议',
      'backToHome': '返回首页',
      'analyzedOn': '分析时间',

      // History
      'historyTitle': '训练历史记录',
      'historySubtitle': '追踪您长期的动作规范度与技术提升',
      'noHistory': '暂无训练记录',
      'deleteConfirm': '确定要删除此条训练记录吗？',
      'itemDeleted': '已删除训练记录',

      // Profile
      'profileTitle': '运动员档案',
      'editProfile': '编辑资料',
      'height': '身高',
      'weight': '体重',
      'gender': '性别',
      'male': '男',
      'female': '女',
      'otherGender': '其他',
      'athleteDetails': '运动员详细信息',
      'physicalMetricsHelp': '身体参数有助于校准相机视角并提高关节角度计算准确度。',
      'profileUpdated': '个人资料更新成功',

      // Settings
      'settingsTitle': '设置',
      'appearance': '外观界面',
      'darkMode': '深色模式',
      'lightMode': '浅色模式',
      'language': '语言设置',
      'selectLanguage': '选择系统语言',
      'serverConfig': '服务器连接配置',
      'serverUrl': 'API服务器地址',
      'aboutApp': '关于 AI Gym Coach',
      'version': '版本号',
    },
  };

  /// Translate key with fallback to English if missing
  String tr(String key) {
    final langMap = _translations[_code] ?? _translations['en']!;
    if (langMap.containsKey(key)) {
      return langMap[key]!;
    }
    return _translations['en']?[key] ?? key;
  }
}

/// Localization delegate for Flutter MaterialApp
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'vi', 'zh'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}

/// Extension on BuildContext for quick access: `context.tr('save')`
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String tr(String key) => AppLocalizations.of(this).tr(key);
}
