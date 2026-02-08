import 'package:flutter/material.dart';
import 'package:life_line/widgets/constants/constants.dart';

// Simple decorations - no shadows, no borders, just clean
class SimpleDecoration {
  static BoxDecoration card() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    );
  }
}

class AppDecorations {
  static const double cardRadius = 16;
  static const BorderRadius cardBorderRadius = BorderRadius.all(
    Radius.circular(16),
  );
  static const double textFieldRadius = 12;
  static const BorderRadius textFieldBorderRadius = BorderRadius.all(
    Radius.circular(12),
  );
  static const double primaryButtonRadius = 12;
  static const double submitButtonRadius = 12;

  static const LinearGradient pageLinearGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF7E8EC), Color(0xFFFFFBFC)],
  );
}

class AppText {
  static const TextStyle base = TextStyle(fontFamily: 'SFPro');

  static const TextStyle appHeader = TextStyle(
    fontFamily: 'SFPro',
    fontWeight: FontWeight.w700,
    fontSize: 18,
    color: AppColors.darkCharcoal,
  );

  static const TextStyle welcomeTitle = TextStyle(
    fontFamily: 'SFPro',
    fontWeight: FontWeight.w700,
    fontSize: 32,
    color: AppColors.darkCharcoal,
  );

  static const TextStyle formTitle = TextStyle(
    fontFamily: 'SFPro',
    fontWeight: FontWeight.w700,
    fontSize: 24,
    color: AppColors.darkCharcoal,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: 'SFPro',
    fontWeight: FontWeight.w500,
    fontSize: 16,
    color: AppColors.textSecondary,
  );

  static const TextStyle formDescription = TextStyle(
    fontFamily: 'SFPro',
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const TextStyle fieldLabel = TextStyle(
    fontFamily: 'SFPro',
    fontWeight: FontWeight.w600,
    fontSize: 14,
    color: AppColors.darkCharcoal,
  );

  static const TextStyle small = TextStyle(
    fontFamily: 'SFPro',
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const TextStyle link = TextStyle(
    fontFamily: 'SFPro',
    fontSize: 14,
    color: AppColors.primaryMaroon,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle submitButton = TextStyle(
    fontFamily: 'SFPro',
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: Colors.white,
  );

  static const TextStyle textFieldHint = TextStyle(
    fontFamily: 'SFPro',
    color: AppColors.textSecondary,
  );
}

class AppButtons {
  static final ButtonStyle primary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryMaroon,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    foregroundColor: Colors.white,
  );

  static final ButtonStyle submit = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryMaroon,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    foregroundColor: Colors.white,
  );

  static final ButtonStyle dialogAgree = FilledButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: AppColors.primaryMaroon,
    side: const BorderSide(color: AppColors.primaryMaroon, width: 1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );
}

class AppContainers {
  static const BoxDecoration pageContainer = BoxDecoration(
    gradient: AppDecorations.pageLinearGradient,
  );

  static BoxDecoration get cardContainer => SimpleDecoration.card();
}

class AppTextFields {
  static InputDecoration textFieldDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppText.textFieldHint,
      filled: true,
      fillColor: Colors.white,
      border: const OutlineInputBorder(
        borderRadius: AppDecorations.textFieldBorderRadius,
        borderSide: BorderSide.none,
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: AppDecorations.textFieldBorderRadius,
        borderSide: BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: AppDecorations.textFieldBorderRadius,
        borderSide: BorderSide(color: AppColors.error, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double xxxxl = 40;
}

class AppSizes {
  static const double primaryButtonHeight = 56;
  static const double submitButtonHeight = 48;
  static const double iconSize = 24;
  static const double primaryIconSize = 26;
}
