class AppConstant {
  // Base URL - Change this to your actual API base URL
  // static const String baseUrl = 'http://localhost:3000/api';
  // static const String baseUrl = 'http://10.0.2.2:3000'; // For emulator testing
  static const String baseUrl = 'https://sharing-charity-app.onrender.com'; // For production

  // Auth Endpoints
  static const String authSignIn = '/auth/signin';
  static const String authSignUp = '/auth/signup';
  static const String authLogout = '/auth/logout';
  static const String authRefresh = '/auth/refresh';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authVerifyOtp = '/auth/verify-otp';
  static const String authResetPassword = '/auth/reset-password';

  // User Endpoints
  static const String getUserProfile = '/users/profile';
  static const String updateUserProfile = '/users';
  static const String getUserById = '/users';

  // Product Endpoints
  static const String getAllProducts = '/items';
  static const String getProductById = '/items';
  static const String createProduct = '/items';
  static const String updateProduct = '/items';
  static const String deleteProduct = '/items';
  static const String createItem = '/items';

  // Category Endpoints
  static const String getAllCategories = '/categories';
  static const String getCategoryById = '/categories';

  // Donation Endpoints
  static const String getDonationCenters = '/charities';
  static const String getDonations = '/donations';
  static const String createDonation = '/donations';

  // Chat Endpoints
  static const String getChatMessages = '/messages';
  static const String sendChatMessage = '/messages';
  static const String getUserChats = '/chat/conversations';

  // Notification Endpoints
  static const String getNotifications = '/notifications';
  static const String markNotificationAsRead = '/notifications/read';

  // Search Endpoints
  static const String searchProducts = '/search/products';

  // Upload Endpoints
  static const String uploadImage = '/upload/image';
  static const String uploadDocument = '/upload/document';

  // Timeouts
  static const int connectTimeout = 15; // seconds
  static const int receiveTimeout = 15; // seconds
}
