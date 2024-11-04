import 'package:health/health.dart';

import '../models/health_widget_config.model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'colors.constants.dart';
import 'icons.constants.dart';

final Map<HealthDataType, HealthWidgetConfig> healthWidgetConfigs = {
  HealthDataType.DIETARY_PROTEIN_CONSUMED: HealthWidgetConfig(
    title: (context) => AppLocalizations.of(context)?.proteinWidgetTitle ?? 'Protein',
    unit: (context) => AppLocalizations.of(context)?.unitGrams ?? 'g',
    icon: IconTypes.proteinIcon,
    color: RepresentationColors.proteinColor,
    goalValue: (goals) => goals.proteinGoal.toDouble(),
    currentValue: (controller) => controller.getProtein,
  ),
  HealthDataType.EXERCISE_TIME: HealthWidgetConfig(
    title: (context) => AppLocalizations.of(context)?.exerciseMinutesWidgetTitle ?? 'Exercise Minutes',
    unit: (context) => AppLocalizations.of(context)?.unitMinutes ?? 'min',
    icon: IconTypes.exerciseIcon,
    color: RepresentationColors.exerciseColor,
    goalValue: (goals) => goals.exerciseMinutesGoal.toDouble(),
    currentValue: (controller) => controller.getExerciseMinutes,
  ),
};
