import 'package:flutter/material.dart';

/// Palette de couleurs africaines pour Dr Green
class AppColors {
  // Couleur primaire : Vert Forêt
  static const Color primary = Color(0xFF408635);

  // Couleur secondaire : Jaune Soleil / Or
  static const Color secondary = Color(0xFFFFB300);

  // Couleur d'accent : Terre Cuite / Rouge Africain
  static const Color accent = Color(0xFFD84315);

  // Couleurs supplémentaires
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // Nuances de vert
  static const Color primaryLight = Color(0xFF6FA660);
  static const Color primaryDark = Color(0xFF2D5F24);

  // Gris
  static const Color greyLight = Color(0xFFF5F5F5);
  static const Color greyMedium = Color(0xFFBDBDBD);
  static const Color greyDark = Color(0xFF424242);

  // Texte
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);
}

/// Styles de texte réutilisables
class AppTextStyles {
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
  );
}

/// Dimensions et espacements
class AppDimensions {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  static const double borderRadius = 12.0;
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusLarge = 16.0;

  static const double cardElevation = 4.0;
  static const double buttonHeight = 56.0;
}

/// Animations
class AppAnimations {
  static const Duration short = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration long = Duration(milliseconds: 500);
}
