import 'package:flutter/material.dart';

class AppTheme {
  static final Color primaryColor = Color(0xFF5C6BC0);
  static final Color accentColor = Color(0xFFFF8A65);
  static final Color backgroundColor = Color(0xFFF5F5F5);
  
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      surface: backgroundColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    fontFamily: 'Roboto',
    textTheme: TextTheme(
      displayLarge: TextStyle(
        color: Colors.black87,
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: Colors.black87,
        fontSize: 16.0,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    ),
  );
  
  static final ThemeData darkTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      surface: Color(0xFF303030),
    ),
    scaffoldBackgroundColor: Color(0xFF303030),
    fontFamily: 'Roboto',
    textTheme: TextTheme(
      displayLarge: TextStyle(
        color: Colors.white,
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: Colors.white,
        fontSize: 16.0,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    ),
  );
}