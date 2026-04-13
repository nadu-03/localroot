import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'helper/initial_binding.dart';
import 'util/app_pages.dart';
import 'util/app_routes.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
