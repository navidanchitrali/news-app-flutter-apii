import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_room_app_getx/utils/app_routes.dart';
import 'package:news_room_app_getx/utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: Themes.appTheme,
      initialRoute: AppRoutes.initial,
      getPages: AppRoutes.routes,
    );
  }
}
