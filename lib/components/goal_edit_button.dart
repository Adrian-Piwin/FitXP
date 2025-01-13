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
  final bool allowNegative;
  final Function(double value) onSave;
  final double? currentValue;

  GoalEditButton({
    super.key,
    this.label = 'Edit Goal',
    required this.unit,
    this.allowDecimals = false,
    this.allowNegative = false,
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
          ? currentValue?.abs().toString() ?? '0'
          : (currentValue?.abs().toInt() ?? 0).toString(),
    );

    bool isNegative = currentValue != null && currentValue! < 0;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Center(child: Text(label)),
              titlePadding: const EdgeInsets.fromLTRB(0, 24, 0, 12),
              titleTextStyle: const TextStyle(
                fontSize: FontSizes.xxlarge,
                color: CoreColors.textColor,
              ),
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 100,
                  child: Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (allowNegative) ...[
                          IconButton(
                            onPressed: () {
                              setState(() => isNegative = !isNegative);
                            },
                            icon: Icon(
                              isNegative ? Icons.remove : Icons.add,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: GapSizes.small),
                        ],
                        SizedBox(
                          width: 120,
                          child: TextField(
                            controller: controller,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: allowDecimals,
                            ),
                            inputFormatters: [
                              if (allowDecimals)
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d*$'))
                              else
                                FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              suffix: Text(unit),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: PaddingSizes.medium,
                                vertical: PaddingSizes.small,
                              ),
                            ),
                            autofocus: true,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: GapSizes.small),
                  ])),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: GapSizes.small),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final value = double.tryParse(controller.text);
                            if (value != null) {
                              onSave(isNegative ? -value : value);
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
