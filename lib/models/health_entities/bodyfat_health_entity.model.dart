import 'package:healthxp/models/health_entities/trend_health_entity.model.dart';

class BodyfatHealthEntity extends TrendHealthEntity {
  BodyfatHealthEntity(super.healthItem, super.goals, super.widgetSize);

  @override
  double get total {
    return super.total * 100;
  }

  @override
  double get average {
    return super.average * 100;
  }
}
