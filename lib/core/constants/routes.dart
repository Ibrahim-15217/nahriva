class Routes {
  Routes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String home = '/home';

  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  static const String submitReport = '/report/submit';
  static const String reportFeed = '/report/feed';
  static const String reportDetail = '/report/:id';

  static const String ecolens = '/ecolens';
  static const String ecolensResult = '/ecolens/result';

  static const String quest = '/quest';
  static const String challenge = '/quest/challenge/:id';

  static const String learn = '/learn';
  static const String learnArticle = '/learn/article/:id';
  static const String learnQuiz = '/learn/quiz/:id';

  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';
  static const String profileBadges = '/profile/badges';
  static const String profileReports = '/profile/reports';

  static const String admin = '/admin';
  static const String adminReports = '/admin/reports';
  static const String adminUsers = '/admin/users';
  static const String adminBroadcast = '/admin/broadcast';
}
