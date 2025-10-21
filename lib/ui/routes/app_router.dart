import 'package:flutter/material.dart';
import 'package:app/ui/screens/home_screen.dart';
import 'package:app/features/calculators/view/area_calculator/area_calculator_screen.dart';
import 'package:app/features/calculators/view/volume_calculator/volume_calculator_screen.dart';
import 'package:app/features/modeling/view/modeling_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String areaCalculator = '/area-calculator';
  static const String volumeCalculator = '/volume-calculator';
  static const String modeling = '/modeling';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case areaCalculator:
        return MaterialPageRoute(builder: (_) => const AreaCalculatorScreen());
      case volumeCalculator:
        return MaterialPageRoute(builder: (_) => const VolumeCalculatorScreen());
      case modeling:
        return MaterialPageRoute(builder: (_) => const ModelingScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}