import 'package:flutter/material.dart';
import 'package:healthcore/components/widget_frame.dart';

class LoadingWidget extends WidgetFrame {
  const LoadingWidget({
    super.key,
    required super.size,
    required super.height,
    super.color,
    super.showShadow
  });

  @override
  Widget buildContent(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
