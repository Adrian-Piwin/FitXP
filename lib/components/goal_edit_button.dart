import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:healthxp/components/widget_frame.dart';
import 'package:healthxp/constants/colors.constants.dart';
import 'package:healthxp/constants/icons.constants.dart';
import '../constants/sizes.constants.dart';

class GoalEditButton extends WidgetFrame {
  final String label;
  final String unit;
  final bool allowDecimals;
  final Function(double value) onSave;
  final double? currentValue;

  GoalEditButton({
    super.key,
    this.label = 'Edit Goal',
    required this.unit,
    this.allowDecimals = false,
    required this.onSave,
    this.currentValue,
  }) : super(
          size: 6,
          height: WidgetSizes.xSmallHeight,
          borderRadius: BorderRadiusSizes.large,
          color: CoreColors.accentAltColor,
          padding: PaddingSizes.small,
        );

  @override
  Widget buildContent(BuildContext context) {
    return InkWell(
      onTap: () => _showEditDialog(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: PaddingSizes.medium,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Centered text
            Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: FontSizes.medium,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            // Right-aligned icon
            Positioned(
              right: 0,
              child: const Icon(
                IconTypes.editIcon,
                size: IconSizes.xsmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final controller = TextEditingController(
      text: allowDecimals
          ? currentValue?.toString() ?? '0'
          : (currentValue?.toInt() ?? 0).toString(),
    );

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(label),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(
              decimal: allowDecimals,
            ),
            inputFormatters: [
              if (allowDecimals)
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))
              else
                FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              suffix: Text(unit),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: PaddingSizes.medium,
                vertical: PaddingSizes.small,
              ),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: PaddingSizes.medium,
                  vertical: PaddingSizes.small,
                ),
              ),
              onPressed: () {
                final value = double.tryParse(controller.text);
                if (value != null) {
                  onSave(value);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
