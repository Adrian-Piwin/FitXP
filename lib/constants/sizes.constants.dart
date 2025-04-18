import 'package:healthcore/models/circular_percent_config.model.dart';

class FontSizes {
  static const double xsmall = 10.0;
  static const double small = 12.0;
  static const double medium = 14.0;
  static const double large = 16.0;
  static const double xlarge = 18.0;
  static const double xxlarge = 24.0;
  static const double xxxlarge = 32.0;
  static const double xxxxlarge = 36.0;
  static const double huge = 120.0;
}

class BorderRadiusSizes {
  static const double small = 6.0;
  static const double medium = 10.0;
  static const double large = 16.0;
}

class IconSizes{
  static const double xsmall = 20.0;
  static const double small = 24.0;
  static const double medium = 28.0;
  static const double large = 32.0;
  static const double xlarge = 36.0;
}

class GapSizes {
  static const double xsmall = 2.0;
  static const double small = 4.0;
  static const double medium = 8.0;
  static const double large = 12.0;
  static const double xlarge = 16.0;
  static const double xxlarge = 20.0;
  static const double xxxlarge = 30.0;
  static const double huge = 60.0;
}

class PaddingSizes {
  static const double small = 4.0;
  static const double medium = 8.0;
  static const double large = 12.0;
  static const double xlarge = 16.0;
  static const double xxlarge = 20.0;
  static const double xxxlarge = 30.0;
}

class PercentIndicatorSizes{
  static const double lineHeightSmall = 6.0;
  static const double lineHeightMedium = 10.0;
  static const double lineHeightMedium2 = 12.0;
  static const double lineHeightLarge = 16.0;
  static const double barRadius = 10.0;
  static const double circularRadiusMedium = 35.0;
  static const double circularRadiusLarge = 40.0;
}

class InputSizes {
  static const double small = 50.0;
  static const double medium = 100.0;
  static const double large = 150.0;
}

class WidgetSizes {
  static const double xxSmallHeight = 40.0;
  static const double xSmallHeight = 90.0;
  static const double smallHeight = 120.0;
  static const double mediumHeight = 145.0;
  static const double largeHeight = 205.0;
}

class CircularPercentWidgetSizes {
  static CircularPercentConfig small = CircularPercentConfig(
    radius: PercentIndicatorSizes.circularRadiusMedium,
    iconSize: IconSizes.small,
    fontSize: FontSizes.medium,
  );

  static CircularPercentConfig medium = CircularPercentConfig(
    radius: PercentIndicatorSizes.circularRadiusMedium,
    iconSize: IconSizes.small,
    fontSize: FontSizes.medium,
  );
}
