import 'package:flutter/material.dart';
import 'app_colors.dart';


class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.backgroundColor,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: AppColors.lightColor,
          letterSpacing: 2,
        ),
        displayMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w500,
          color: AppColors.secondaryColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.greyTextColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.greyTextColor,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryColor,
          shadowColor: AppColors.primaryColor,
          elevation: 20,
          shape: const StadiumBorder(),
          minimumSize: const Size.fromHeight(60),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.all(AppColors.primaryColor),
      ),
    );
  }
}
