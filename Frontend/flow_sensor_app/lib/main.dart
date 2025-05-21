import 'package:flow_sensor_app/modules/device_summary/device_summary_controller.dart';
import 'package:flow_sensor_app/modules/device_summary/device_summary_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'modules/welcome/welcome_view.dart';
import 'modules/welcome/welcome_controller.dart';
import 'modules/link_device/link_device_view.dart';
import 'modules/link_device/link_device_controller.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  runApp(MyApp(onboardingComplete: onboardingComplete));
}

class MyApp extends StatelessWidget {
  final bool onboardingComplete;

  const MyApp({required this.onboardingComplete});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Monitor de Agua',
      debugShowCheckedModeBanner: false,
      initialRoute:
          onboardingComplete ? AppRoutes.linkDevice : AppRoutes.welcome,
      getPages: [
        GetPage(
          name: AppRoutes.welcome,
          page: () => WelcomeView(),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => WelcomeController());
          }),
        ),
        GetPage(
          name: AppRoutes.linkDevice,
          page: () => LinkDeviceView(),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => LinkDeviceController());
          }),
        ),
        GetPage(
          name: AppRoutes.deviceSummary,
          page: () => DeviceSummaryView(),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => DeviceSummaryController());
          }),
        ),
      ],
    );
  }
}
