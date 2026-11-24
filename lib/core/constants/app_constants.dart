/// NONGKI App Constants
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'NONGKI';
  static const String appVersion = '1.0.0';

  // SharedPreferences keys
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';
  static const String keyAuthToken = 'auth_token';

  // Padding / Spacing
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 20.0;
  static const double paddingXL = 24.0;
  static const double paddingXXL = 32.0;

  // Border radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusFull = 100.0;

  // Image placeholder
  static const String placeholderPlace = 'assets/images/placeholder_place.png';
  static const String placeholderMenu = 'assets/images/placeholder_menu.png';

  // Budget categories persis seperti referensi desain
  static const List<Map<String, dynamic>> budgetRanges = [
    {'label': '< Rp20rb', 'min': 0, 'max': 20000},
    {'label': 'Rp20-35rb', 'min': 20000, 'max': 35000},
    {'label': 'Rp35-50rb', 'min': 35000, 'max': 50000},
  ];

  // Place categories
  static const List<String> placeCategories = [
    'Semua',
    'Kafe',
    'Outdoor',
    'Working Space',
    'Restoran',
    'Kedai',
  ];

  // Order status
  static const String statusPendingPayment = 'pending_payment';
  static const String statusProcessing = 'processing';
  static const String statusReady = 'ready';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';
  static const String statusFailed = 'failed';

  // Payment methods
  static const String paymentCash = 'cash';
  static const String paymentTransfer = 'transfer';
}
