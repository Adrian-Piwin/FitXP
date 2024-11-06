import '../models/health_widget_config.model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'colors.constants.dart';
import 'icons.constants.dart';

final Map<String, HealthWidgetConfig> healthWidgetConfigs = {
  "protein": HealthWidgetConfig(
    title: (context) => AppLocalizations.of(context)?.proteinWidgetTitle ?? 'Protein',
    subtitle: (context, goals, healthData) => "${(goals.proteinGoal.toDouble() - healthData.getProtein).toStringAsFixed(0) + (AppLocalizations.of(context)?.unitGrams ?? 'g')} left",
    unit: (context) => AppLocalizations.of(context)?.unitGrams ?? 'g',
    icon: IconTypes.proteinIcon,
    color: RepresentationColors.proteinColor,
    size: 2,
    goalValue: (goals) => goals.proteinGoal.toDouble(),
    currentValue: (healthData) => healthData.getProtein,
  ),
  "exercise_time": HealthWidgetConfig(
    title: (context) => AppLocalizations.of(context)?.exerciseMinutesWidgetTitle ?? 'Exercise Minutes',
    subtitle: (context, goals, healthData) => "${(goals.exerciseMinutesGoal.toDouble() - healthData.getExerciseMinutes).toStringAsFixed(0) + (AppLocalizations.of(context)?.unitGrams ?? 'min')} left",
    unit: (context) => AppLocalizations.of(context)?.unitMinutes ?? 'min',
    icon: IconTypes.exerciseIcon,
    color: RepresentationColors.exerciseColor,
    size: 2,
    goalValue: (goals) => goals.exerciseMinutesGoal.toDouble(),
    currentValue: (controller) => controller.getExerciseMinutes,
  ),
};
