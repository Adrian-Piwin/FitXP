enum Rank {
  bronze,
  silver,
  gold,
  diamond;

  String get displayName => switch (this) {
    Rank.bronze => 'Bronze',
    Rank.silver => 'Silver',
    Rank.gold => 'Gold',
    Rank.diamond => 'Diamond',
  };
} 
