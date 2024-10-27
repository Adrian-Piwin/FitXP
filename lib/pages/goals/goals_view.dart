import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/bottom_nav_bar.dart';
import 'goals_controller.dart';
import '../../enums/phasetype.enum.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GoalsView extends StatelessWidget {
  const GoalsView({super.key});

  static const String routeName = "/goals";

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GoalsController(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.goalsPageTitle),
          actions: [
            Consumer<GoalsController>(
              builder: (context, controller, _) {
                return IconButton(
                  icon: Icon(Icons.save),
                  onPressed: controller.isLoading
                      ? null
                      : () {
                          controller.saveGoals();
                        },
                );
              },
            ),
          ],
        ),
        body: Consumer<GoalsController>(
          builder: (context, controller, _) {
            if (controller.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            return ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                // Current Phase Dropdown
                ListTile(
                  title: Text(AppLocalizations.of(context)!.currentPhaseTitle),
                  trailing: DropdownButton<PhaseType>(
                    value: controller.goal!.phaseType,
                    items: PhaseType.values.map((PhaseType phase) {
                      return DropdownMenuItem<PhaseType>(
                        value: phase,
                        child: Text(phase.name),
                      );
                    }).toList(),
                    onChanged: (PhaseType? newPhase) {
                      if (newPhase != null) {
                        controller.updateGoalField('phaseType', newPhase);
                      }
                    },
                  ),
                ),
                Divider(),
                // Calorie Goal
                _buildNumberInputTile(
                  context,
                  title: AppLocalizations.of(context)!.calorieGoalTitle,
                  initialValue: controller.goal!.calorieGoal.toString(),
                  onChanged: (value) {
                    int intValue = int.tryParse(value) ?? 0;
                    controller.updateGoalField('calorieGoal', intValue);
                  },
                ),
                // Exercise Minutes Goal
                _buildNumberInputTile(
                  context,
                  title: AppLocalizations.of(context)!.exerciseMinutesGoalTitle,
                  initialValue:
                      controller.goal!.exerciseMinutesGoal.toString(),
                  onChanged: (value) {
                    int intValue = int.tryParse(value) ?? 0;
                    controller.updateGoalField('exerciseMinutesGoal', intValue);
                  },
                ),
                // Weight Goal
                _buildNumberInputTile(
                  context,
                  title: AppLocalizations.of(context)!.weightGoalTitle,
                  initialValue: controller.goal!.weightGoal.toString(),
                  onChanged: (value) {
                    double doubleValue = double.tryParse(value) ?? 0.0;
                    controller.updateGoalField('weightGoal', doubleValue);
                  },
                ),
                // Body Fat Percentage Goal
                _buildNumberInputTile(
                  context,
                  title: AppLocalizations.of(context)!.bodyFatGoalTitle,
                  initialValue: controller.goal!.bodyFatGoal.toString(),
                  onChanged: (value) {
                    double doubleValue = double.tryParse(value) ?? 0.0;
                    controller.updateGoalField('bodyFatGoal', doubleValue);
                  },
                ),
                // Protein Goal
                _buildNumberInputTile(
                  context,
                  title: AppLocalizations.of(context)!.proteinGoalTitle,
                  initialValue: controller.goal!.proteinGoal.toString(),
                  onChanged: (value) {
                    int intValue = int.tryParse(value) ?? 0;
                    controller.updateGoalField('proteinGoal', intValue);
                  },
                ),
                // Steps Goal
                _buildNumberInputTile(
                  context,
                  title: AppLocalizations.of(context)!.stepsGoalTitle,
                  initialValue: controller.goal!.stepsGoal.toString(),
                  onChanged: (value) {
                    int intValue = int.tryParse(value) ?? 0;
                    controller.updateGoalField('stepsGoal', intValue);
                  },
                ),
                // Sleep Goal
                _buildTimeInputTile(
                  context,
                  title: AppLocalizations.of(context)!.sleepGoalTitle,
                  initialValue: _durationToString(controller.goal!.sleepGoal),
                  onChanged: (value) {
                    Duration duration = _parseDuration(value);
                    controller.updateGoalField('sleepGoal', duration);
                  },
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 1)
      ),
    );
  }

  Widget _buildNumberInputTile(
    BuildContext context, {
    required String title,
    required String initialValue,
    required Function(String) onChanged,
  }) {
    return ListTile(
      title: Text(title),
      trailing: SizedBox(
        width: 100,
        child: TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '0',
          ),
          controller: TextEditingController(text: initialValue),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTimeInputTile(
    BuildContext context, {
    required String title,
    required String initialValue,
    required Function(String) onChanged,
  }) {
    return ListTile(
      title: Text(title),
      trailing: SizedBox(
        width: 100,
        child: TextField(
          keyboardType: TextInputType.datetime,
          decoration: InputDecoration(
            hintText: '8:30',
          ),
          controller: TextEditingController(text: initialValue),
          onChanged: onChanged,
        ),
      ),
    );
  }

  String _durationToString(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    return '$hours:${minutes.toString().padLeft(2, '0')}';
  }

  Duration _parseDuration(String input) {
    List<String> parts = input.split(':');
    int hours = int.tryParse(parts[0]) ?? 0;
    int minutes = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return Duration(hours: hours, minutes: minutes);
  }
}
