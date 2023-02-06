import 'package:flutter/material.dart';

class ColorGradients {
  BoxDecoration dayGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        Colors.orange[500]!,
        Colors.red,
      ],
    ),
  );

  BoxDecoration nightGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.blue[900]!,
        Colors.grey[900]!,
      ],
    ),
  );

  BoxDecoration getGradient(bool isDay) {
    if (isDay) {
      return dayGradient;
    } else {
      return nightGradient;
    }
  }
}

class ColorThemes {
  ThemeData darkTheme = ThemeData.dark().copyWith(
    //useMaterial3: true,
    colorScheme: const ColorScheme.dark().copyWith(
      primary: Colors.tealAccent,
      secondary: Colors.limeAccent,
    ),
  );

  ThemeData lightTheme = ThemeData.light().copyWith(
    //useMaterial3: true,
    colorScheme: const ColorScheme.light().copyWith(
      primary: Colors.blueAccent,
      secondary: Colors.purple,
    ),
  );

  ThemeData getTheme(bool isDay) {
    if (isDay) {
      return lightTheme;
    } else {
      return darkTheme;
    }
  }
}
