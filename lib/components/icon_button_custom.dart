import 'package:flutter/material.dart';
import 'package:healthxp/constants/colors.constants.dart';
import 'package:healthxp/constants/sizes.constants.dart';

class IconButtonCustom extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isElevated;
  final Color? backgroundColor;
  final Color? textColor;

  const IconButtonCustom({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
    this.isElevated = true,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = isElevated
        ? ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? CoreColors.accentAltColor,
            foregroundColor: textColor ?? CoreColors.textColor,
            padding: const EdgeInsets.all(PaddingSizes.large),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
            ),
          )
        : TextButton.styleFrom(
            backgroundColor: backgroundColor ?? CoreColors.accentAltColor,
            foregroundColor: textColor ?? CoreColors.textColor,
            padding: const EdgeInsets.all(PaddingSizes.large),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
            ),
          );

    final Widget buttonChild = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: PaddingSizes.medium,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: FontSizes.medium,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : Icon(
                    icon,
                    size: IconSizes.medium,
                  ),
          ),
        ],
      ),
    );

    return isElevated
        ? ElevatedButton(
            onPressed: onPressed,
            style: buttonStyle,
            child: buttonChild,
          )
        : TextButton(
            onPressed: onPressed,
            style: buttonStyle,
            child: buttonChild,
          );
  }
} 
