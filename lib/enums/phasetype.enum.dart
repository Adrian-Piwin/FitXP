import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; 

enum PhaseType { 
  none,
  cutting, 
  bulking 
}

String phaseTypeToString(BuildContext context, PhaseType phase) {
  final appLocalizations = AppLocalizations.of(context)!;
  switch (phase) {
    case PhaseType.none:
      return appLocalizations.phaseTypeNone;
    case PhaseType.cutting:
      return appLocalizations.phaseTypeCutting;
    case PhaseType.bulking:
      return appLocalizations.phaseTypeBulking;
    default:
      return '';
  }
}

PhaseType phaseTypeFromString(String value) {
  switch (value.toLowerCase()) {
    case 'cutting':
      return PhaseType.cutting;
    case 'bulking':
      return PhaseType.bulking;
    default:
      return PhaseType.none;
  }
}
