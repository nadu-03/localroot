import 'package:get/get.dart';

import '../features/home/bindings/home_binding.dart';
import '../features/language/views/language_view.dart';
import '../features/menu/views/nav_bar_screen.dart';
import '../features/onboarding/bindings/onboarding_binding.dart';
import '../features/onboarding/views/onboarding_view.dart';
import '../features/onboarding/views/login_view.dart';
import '../features/onboarding/views/signup_view.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = <GetPage<dynamic>>[
    GetPage<dynamic>(
      name: AppRoutes.onboarding,
      page: OnboardingView.new,
      binding: OnboardingBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.login,
      page: LoginView.new,
      binding: OnboardingBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.signup,
      page: SignUpView.new,
      binding: OnboardingBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.home,
      page: NavBarScreen.new,
      binding: HomeBinding(),
    ),
    GetPage<dynamic>(name: AppRoutes.language, page: LanguageView.new),
  ];
}
