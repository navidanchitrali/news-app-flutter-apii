import 'package:flutter/material.dart';
import 'package:news_room_app_getx/constants/color_constants.dart';

class Themes {
  static final appTheme = ThemeData(
    primaryColor: AppColors.bluebackground,
    scaffoldBackgroundColor: AppColors.lightGrey,
    buttonTheme: const ButtonThemeData(buttonColor: AppColors.orangeWeb),
    appBarTheme: const AppBarTheme(backgroundColor: AppColors.bluebackground),
    colorScheme:
        ColorScheme.fromSwatch().copyWith(secondary: AppColors.orangeWeb),
  );
}
