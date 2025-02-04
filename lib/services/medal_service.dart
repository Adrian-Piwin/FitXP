import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:healthxp/constants/colors.constants.dart';
import 'package:healthxp/enums/health_item_type.enum.dart';

class MedalInfo {
  final IconData icon;
  final Color color;
  final String title;

  const MedalInfo({
    required this.icon,
    required this.color,
    required this.title,
  });
}

class MedalLevel {
  static const bronze = MedalInfo(
    icon: FontAwesomeIcons.medal,
    color: CoreColors.coreBronze,
    title: '',
  );
  
  static const silver = MedalInfo(
    icon: FontAwesomeIcons.medal,
    color: CoreColors.coreSilver,
    title: '',
  );
  
  static const gold = MedalInfo(
    icon: FontAwesomeIcons.medal,
    color: CoreColors.coreGold,
    title: '',
  );

  static const none = MedalInfo(
    icon: FontAwesomeIcons.medal,
    color: Colors.grey,
    title: 'Just Getting Started',
  );
}

class MedalTitles {
  static const Map<HealthItemType, Map<String, String>> titles = {
    HealthItemType.steps: {
      'bronze': 'Casual Walker',
      'silver': 'Step Master',
      'gold': 'Walking Legend',
    },
    HealthItemType.workoutTime: {
      'bronze': 'Gym Rookie',
      'silver': 'Iron Warrior',
      'gold': 'Strength Legend',
    },
    HealthItemType.cardioMinutes: {
      'bronze': 'Cardio Starter',
      'silver': 'Endurance Elite',
      'gold': 'Cardio King',
    },
    HealthItemType.sleep: {
      'bronze': 'Rest Seeker',
      'silver': 'Dream Master',
      'gold': 'Sleep Champion',
    },
    HealthItemType.proteinIntake: {
      'bronze': 'Protein Novice',
      'silver': 'Protein Pro',
      'gold': 'Protein Perfect',
    },
  };
}

class MedalService {
  static MedalInfo getMedalInfo(HealthItemType type, int completedDays) {
    if (completedDays <= 0) return MedalLevel.none;

    final titles = MedalTitles.titles[type];
    if (titles == null) return MedalLevel.none;

    if (completedDays <= 2) {
      return MedalInfo(
        icon: MedalLevel.bronze.icon,
        color: MedalLevel.bronze.color,
        title: titles['bronze']!,
      );
    } else if (completedDays <= 5) {
      return MedalInfo(
        icon: MedalLevel.silver.icon,
        color: MedalLevel.silver.color,
        title: titles['silver']!,
      );
    } else {
      return MedalInfo(
        icon: MedalLevel.gold.icon,
        color: MedalLevel.gold.color,
        title: titles['gold']!,
      );
    }
  }
} 
