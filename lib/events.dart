import 'package:event_bus/event_bus.dart';

EventBus eventBus = EventBus();

class ChartUpdated {
  String name;

  ChartUpdated(this.name);
}