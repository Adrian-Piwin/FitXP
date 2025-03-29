import 'package:flutter/material.dart';
import 'package:healthcore/enums/rank.enum.dart';

class RankModel {
  final Rank rank;
  final String fact;
  final IconData icon;
  final Color color;

  const RankModel({
    required this.rank,
    required this.fact,
    required this.icon,
    required this.color,
  });
} 
