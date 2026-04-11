import 'package:flutter/material.dart';
import 'package:permis_app/features/session/presentation/screens/header_screen.dart';
import 'package:permis_app/features/session/presentation/screens/candidates_screen.dart';

class AppRouter {
  AppRouter._();

  static const String candidates = '/';
  static const String header = '/header';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case candidates:
        return _buildRoute(const CandidatesScreen());
      case header:
        return _buildRoute(const HeaderScreen());
      default:
        return _buildRoute(
          const Scaffold(body: Center(child: Text('الصفحة غير موجودة'))),
        );
    }
  }

  static MaterialPageRoute _buildRoute(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}
