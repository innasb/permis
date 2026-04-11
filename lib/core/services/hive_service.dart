import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:permis_app/core/constants/app_constants.dart';

class HiveService {
  HiveService._();

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(AppConstants.reportsBoxName);
  }

  static Box<String> getReportsBox() {
    return Hive.box<String>(AppConstants.reportsBoxName);
  }
}
