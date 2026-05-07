import 'package:hive_flutter/hive_flutter.dart';
import '../models/schedule_model.dart';

class LocalDbService {
  static const String scheduleBoxName = 'schedulesBox';
  static const String appBoxName = 'appBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ScheduleModelAdapter());
    await Hive.openBox<ScheduleModel>(scheduleBoxName);
    await Hive.openBox(appBoxName);
  }

  static Box<ScheduleModel> get scheduleBox => Hive.box<ScheduleModel>(scheduleBoxName);
  static Box get appBox => Hive.box(appBoxName);

  // Generic Storage Methods
  static Future<void> saveData(String key, dynamic data) async {
    await appBox.put(key, data);
  }

  static dynamic getData(String key) {
    return appBox.get(key);
  }

  // Schedule Specific
  static Future<void> addSchedule(ScheduleModel schedule) async {
    await scheduleBox.put(schedule.id, schedule);
  }

  static List<ScheduleModel> getAllSchedules() {
    return scheduleBox.values.toList();
  }

  static Future<void> deleteSchedule(String id) async {
    await scheduleBox.delete(id);
  }
}
