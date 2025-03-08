import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:healthxp/constants/colors.constants.dart';
import 'package:healthxp/enums/rank.enum.dart';
import 'package:healthxp/models/rank.model.dart';

class RankDefinitions {
  static final Map<Rank, RankModel> ranks = {
    Rank.bronze: RankModel(
      rank: Rank.bronze,
      fact: 'You\'re building healthy habits! Regular exercise can improve your mood by releasing endorphins, nature\'s feel-good hormones.',
      icon: FontAwesomeIcons.medal,
      color: CoreColors.coreBronze,
    ),
    Rank.silver: RankModel(
      rank: Rank.silver,
      fact: 'Your dedication is paying off! Consistent exercise can increase your resting metabolic rate, helping you burn more calories even when resting.',
      icon: FontAwesomeIcons.award,
      color: CoreColors.coreSilver,
    ),
    Rank.gold: RankModel(
      rank: Rank.gold,
      fact: 'You\'re in the fitness elite! Regular exercise can add up to 7 years to your life expectancy and significantly improve your quality of life.',
      icon: FontAwesomeIcons.trophy,
      color: CoreColors.coreGold,
    ),
    Rank.diamond: RankModel(
      rank: Rank.diamond,
      fact: 'You\'re among the top 1% of health enthusiasts! Your level of activity is associated with improved cognitive function and a 30% lower risk of depression.',
      icon: FontAwesomeIcons.gem,
      color: CoreColors.coreDiamond,
    ),
  };
} 
