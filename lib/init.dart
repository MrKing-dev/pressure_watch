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
    print('Got initial location from Init.setLocationCity');

    String city = "";

    await placemarkFromCoordinates(position.latitude, position.longitude)
        .then((placemarks) {
      if (placemarks.isNotEmpty) {
        var output = placemarks[0];
        print('Created placemark from Init.setLocationCity');
        print(output);
        city = '${output.locality}, ${output.administrativeArea}';
      } else {
        print('No placemarks from Init.setLocationCity');
      }
    });
    print('Returning specific location from Init.setLocationCity: $city');
    return city;
  }

  Future<void> loadChartData() async {
    print('Clearing chart data');
    chartData = {};
    print('Getting data from weatherPoints');
    chartData = await Data().populateWeatherGraph();
    print('Set chart data from weatherPoints');
  }

  Future<String> initialize() async {
    print('Beginning to get location from Init.initialize');
    var output = await setLocationCity();
    print('Location set, getting chart data within Init.initialize');
    currentWeather = await Data().getCurrentWeatherData();
    print('Got current weather data from Init.initialize');
    await loadChartData();
    print('Finished loading chart data from Init.initialize');
    return output;
  }
}
