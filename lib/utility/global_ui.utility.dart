import 'package:flutter/material.dart';
import 'package:healthcore/constants/colors.constants.dart';
import 'package:healthcore/constants/sizes.constants.dart';

class GlobalUI {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  static void showError(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: CoreColors.errorColor,
              size: IconSizes.medium,
            ),
            const SizedBox(width: GapSizes.medium),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: CoreColors.errorColor,
                  fontSize: FontSizes.medium,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: CoreColors.foregroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(PaddingSizes.medium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
          side: BorderSide(
            color: CoreColors.errorColor,
            width: 1,
          ),
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }
} 
