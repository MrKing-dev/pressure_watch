import 'package:flutter/material.dart';
import 'package:pressure_watch/data.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data.dart';
import 'dart:io';
import 'dart:convert';

class Init {
  static var chartData = {};
  static var currentWeather;

  Future<String> setLocationCity() async {
    Position position = await Data().determinePosition();
    print('Got initial location');

    var output = placemarkFromCoordinates(position.latitude, position.longitude)
        .then((placemarks) {
      var output;
      if (placemarks.isNotEmpty) {
        output = placemarks[0];
      } else {
        print('No placemarks');
      }
      print('Created placemark');
      print(output);
      return '${output.locality}, ${output.administrativeArea}';
    });
    print('Returning specific location');
    return output;
  }

  Future<void> loadChartData() async {
    print('Clearing chart data');
    chartData = {};
    print('Getting data from weatherPoints');
    chartData = await Data().populateWeatherGraph();
    print('Set chart data from weatherPoints');
  }

  Future<String> initialize() async {
    print('Beginning to get location.');
    var output = await setLocationCity();
    print('Location set, getting chart data');
    currentWeather = await Data().getCurrentWeatherData();
    print('Got current weather data');
    await loadChartData();
    print('Finished loading chart data');
    return output;
  }
}
