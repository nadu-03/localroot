import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'helper/initial_binding.dart';
import 'util/app_pages.dart';
import 'util/app_routes.dart';
import 'util/app_constant.dart';
import 'theme/app_theme.dart';
import 'data/api/api_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API manager with baseUrl from AppConstant
  ApiManager.instance.init(baseUrl: AppConstant.baseUrl, enableLogs: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Localroot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.onboarding,
      getPages: AppPages.routes,
    );
  }
}
