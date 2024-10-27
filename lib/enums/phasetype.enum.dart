enum PhaseType { 
  none,
  cutting, 
  bulking 
}

extension PhaseTypeExtension on PhaseType {
  String get name {
    switch (this) {
      case PhaseType.none:
        return 'None';
      case PhaseType.cutting:
        return 'Cutting';
      case PhaseType.bulking:
        return 'Bulking';
    }
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
