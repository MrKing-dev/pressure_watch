import 'package:flutter/material.dart';

Widget WeatherIcon(iconText) {
  String name = iconText;

  return Image.asset('assets/weathericons/$name.png');
}
