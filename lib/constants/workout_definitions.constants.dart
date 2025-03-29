import 'package:flutter/material.dart';
import 'package:healthcore/constants/icons.constants.dart';

class WorkoutDefinitions {
  static String getWorkoutName(String workoutType) {
    switch (workoutType.toUpperCase()) {
      case 'RUNNING':
      case 'RUNNING_TREADMILL':
        return 'Running';
      case 'WALKING':
      case 'WHEELCHAIR_WALK_PACE':
        return 'Walking';
      case 'BIKING':
        return 'Cycling';
      case 'SWIMMING':
      case 'SWIMMING_POOL':
        return 'Swimming';
      case 'SWIMMING_OPEN_WATER':
        return 'Open Water Swim';
      case 'HIGH_INTENSITY_INTERVAL_TRAINING':
        return 'HIIT';
      case 'MIND_AND_BODY':
        return 'Mind & Body';
      case 'GUIDED_BREATHING':
        return 'Breathing';
      case 'SOCIAL_DANCE':
      case 'DANCING':
        return 'Dancing';
      case 'STAIR_CLIMBING':
      case 'STAIR_CLIMBING_MACHINE':
      case 'STAIRS':
        return 'Stair Climbing';
      case 'STRENGTH_TRAINING':
      case 'TRADITIONAL_STRENGTH_TRAINING':
        return 'Strength Training';
      case 'FUNCTIONAL_STRENGTH_TRAINING':
        return 'Functional Training';
      case 'CROSS_COUNTRY_SKIING':
        return 'Cross Country Ski';
      case 'PREPARATION_AND_RECOVERY':
        return 'Recovery';
      
      default:
        return workoutType.split('_').map((word) => 
          word.substring(0, 1).toUpperCase() + 
          word.substring(1).toLowerCase()
        ).join(' ');
    }
  }

  static IconData getWorkoutIcon(String workoutType) {
    switch (workoutType.toUpperCase()) {
      // Cardio
      case 'RUNNING':
      case 'RUNNING_TREADMILL':
      case 'WHEELCHAIR_RUN_PACE':
        return IconTypes.runningIcon;
      case 'WALKING':
      case 'WHEELCHAIR_WALK_PACE':
        return IconTypes.walkingIcon;
      case 'BIKING':
      case 'HAND_CYCLING':
        return IconTypes.cyclingIcon;
      case 'SWIMMING':
      case 'SWIMMING_POOL':
      case 'SWIMMING_OPEN_WATER':
        return IconTypes.swimmingIcon;
      case 'HIKING':
        return IconTypes.hikingIcon;
      case 'ELLIPTICAL':
      case 'STAIR_CLIMBING':
      case 'STAIR_CLIMBING_MACHINE':
      case 'STAIRS':
        return IconTypes.stairsIcon;
      
      // Strength Training
      case 'STRENGTH_TRAINING':
      case 'TRADITIONAL_STRENGTH_TRAINING':
      case 'FUNCTIONAL_STRENGTH_TRAINING':
      case 'WEIGHTLIFTING':
        return IconTypes.strengthIcon;
      case 'CALISTHENICS':
        return IconTypes.calisthenicsIcon;
      
      // HIIT & Cross Training
      case 'HIGH_INTENSITY_INTERVAL_TRAINING':
      case 'CROSS_TRAINING':
      case 'MIXED_CARDIO':
        return IconTypes.streakIcon;
      
      // Mind & Body
      case 'YOGA':
      case 'FLEXIBILITY':
      case 'PILATES':
      case 'MIND_AND_BODY':
      case 'GUIDED_BREATHING':
      case 'TAI_CHI':
        return IconTypes.mindBodyIcon;
      
      // Dance & Rhythm
      case 'CARDIO_DANCE':
      case 'DANCING':
      case 'SOCIAL_DANCE':
        return IconTypes.danceIcon;
      
      // Combat Sports
      case 'BOXING':
      case 'KICKBOXING':
      case 'MARTIAL_ARTS':
      case 'WRESTLING':
        return IconTypes.combatIcon;
      
      // Court Sports
      case 'BASKETBALL':
        return IconTypes.basketballIcon;
      case 'VOLLEYBALL':
      case 'TENNIS':
      case 'BADMINTON':
      case 'TABLE_TENNIS':
      case 'PICKLEBALL':
      case 'SQUASH':
      case 'RACQUETBALL':
        return IconTypes.racketSportsIcon;
      
      // Field Sports
      case 'SOCCER':
        return IconTypes.soccerIcon;
      case 'BASEBALL':
      case 'SOFTBALL':
        return IconTypes.baseballIcon;
      case 'FOOTBALL':
      case 'RUGBY':
      case 'CRICKET':
      case 'HOCKEY':
        return IconTypes.footballIcon;
      
      // Water Sports
      case 'WATER_FITNESS':
      case 'WATER_SPORTS':
      case 'WATER_POLO':
      case 'SURFING':
      case 'ROWING':
      case 'PADDLE_SPORTS':
        return IconTypes.waterSportsIcon;
      
      // Winter Sports
      case 'SKIING':
      case 'SNOWBOARDING':
      case 'CROSS_COUNTRY_SKIING':
      case 'SNOW_SPORTS':
        return IconTypes.skiingIcon;
      
      // Recovery
      case 'COOLDOWN':
      case 'PREPARATION_AND_RECOVERY':
        return IconTypes.recoveryIcon;
      
      default:
        return IconTypes.defaultWorkoutIcon;
    }
  }
}
