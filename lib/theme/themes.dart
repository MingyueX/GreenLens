import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'colors.dart';

extension Themes on ThemeData {
  // TODO: implement
  static ThemeData get darkTheme => ThemeData(
        primarySwatch: Colors.blue,
      );

  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.baseWhite,
        primaryColor: AppColors.baseBlack,
        highlightColor: AppColors.baseWhite,
        dividerColor: AppColors.grey,
        colorScheme: const ColorScheme.light().copyWith(
          primary: AppColors.primaryGreen,
          secondary: AppColors.grey,
        ),
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
        }),
        textTheme: TextTheme(
          headlineLarge: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 28.0,
            fontWeight: FontWeight.w700,
            color: AppColors.baseBlack,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14.0,
            fontWeight: FontWeight.w700,
            color: AppColors.baseBlack.withOpacity(0.8),
          ),
          bodyLarge: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            color: AppColors.baseBlack,
          ),
          bodySmall: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
            color: AppColors.grey,
          ),
          bodyMedium: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16.0,
            fontWeight: FontWeight.w400,
            color: AppColors.baseBlack,
          ),
          labelLarge: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            color: AppColors.baseWhite,
          ),
          labelMedium: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20.0,
            fontWeight: FontWeight.w400,
            color: AppColors.grey,
          ),
          labelSmall: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 12.0,
            fontWeight: FontWeight.w400,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12.0,
              fontWeight: FontWeight.w400,
              color: AppColors.grey),
          floatingLabelStyle: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12.0,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryGreen),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryGreen, width: 2.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.grey, width: 1.0),
          ),
          focusColor: AppColors.primaryGreen,
        ),
      );
}

extension CustomTextTheme on TextTheme {
  TextStyle get greenTitle {
    return headlineLarge?.copyWith(color: AppColors.primaryGreen) ??
        const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 28.0,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryGreen,
        );
  }

  TextStyle get dateLabel {
    return headlineMedium?.copyWith(color: AppColors.primaryGreen) ??
        const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14.0,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryGreen,
        );
  }

  TextStyle get plainButton {
    return labelLarge?.copyWith(color: AppColors.primaryGreen) ??
        const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryGreen,
        );
  }

  TextStyle get appbarTitle {
    return labelMedium?.copyWith(color: AppColors.baseWhite, fontWeight: FontWeight.w600) ??
        const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: AppColors.baseWhite,
        );
  }

  TextStyle get bodyMediumBold {
    return bodyMedium?.copyWith(fontWeight: FontWeight.w600) ??
        const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          color: AppColors.baseBlack,
        );
  }
}
