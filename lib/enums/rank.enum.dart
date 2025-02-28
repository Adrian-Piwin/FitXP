enum Rank {
  bronze,
  silver,
  gold,
  platinum,
  diamond;

  String get displayName => switch (this) {
    Rank.bronze => 'Bronze',
    Rank.silver => 'Silver',
    Rank.gold => 'Gold',
    Rank.platinum => 'Platinum',
    Rank.diamond => 'Diamond',
  };
} 
