import 'package:flutter/material.dart';
import 'package:permis_app/app.dart';
import 'package:permis_app/core/services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const PermisApp());
}
