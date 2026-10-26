import 'stop.dart';
import 'poi.dart';

class StopOrPoi {
  final Stop stop;
  final Poi? poi;

  const StopOrPoi.fromStop(this.stop) : poi = null;
  const StopOrPoi.fromPoi({required this.stop, required Poi poiRef}) : poi = poiRef;

  String get displayName => poi?.name ?? stop.name;
  String get displaySubtitle => poi != null ? stop.name : stop.city;
  bool get isPoi => poi != null;
}
