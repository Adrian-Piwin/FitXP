import 'package:flutter/material.dart';

class SmallWidgetItem extends StatelessWidget {
  final String title;

  const SmallWidgetItem({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    // Width is set in the parent
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
