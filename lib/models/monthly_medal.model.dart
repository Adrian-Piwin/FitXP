import 'package:flutter/material.dart';
import 'package:healthcore/constants/medal_definitions.constants.dart';
import 'package:healthcore/enums/health_item_type.enum.dart';

class Medal {
  final String id;
  final String title;
  final String description;
  final IconData icon;  // Placeholder for now, will be image later
  final Color color;
  final bool isEarned;
  final HealthItemType type;
  final double requirement;
  final int tier;
  final MedalType medalType;

  const Medal({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isEarned,
    required this.type,
    required this.requirement,
    required this.tier,
    required this.medalType,
  });
}
