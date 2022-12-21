import 'package:collection/collection.dart';
import 'data.dart';

class WeatherPoint {
  final double x;
  final double y;
  final String z;
  WeatherPoint({required this.x, required this.y, required this.z});
}

Future<List> weatherPoints(daysToRun) async {
  print('Waiting for data from populateWeatherGraph');
  var data = await Data().populateWeatherGraph(daysToRun);
  print('Got data from populateWeatherGraph');
  return data;
}
