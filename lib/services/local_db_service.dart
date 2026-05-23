import 'package:hive_flutter/hive_flutter.dart';
import '../models/schedule_model.dart';

class LocalDbService {
  static const String appBoxName = 'appBox';
  static const String usersBoxName = 'usersBox';

  static String? currentUser;
  static Box<ScheduleModel>? _userScheduleBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ScheduleModelAdapter());
    await Hive.openBox(appBoxName);
    await Hive.openBox(usersBoxName);
  }

  static Box get appBox => Hive.box(appBoxName);
  static Box get usersBox => Hive.box(usersBoxName);

  static Future<void> initUser(String username) async {
    currentUser = username;
    final boxName = 'schedulesBox_$username';
    if (!Hive.isBoxOpen(boxName)) {
      _userScheduleBox = await Hive.openBox<ScheduleModel>(boxName);
    } else {
      _userScheduleBox = Hive.box<ScheduleModel>(boxName);
    }
  }

  static Future<void> closeUser() async {
    if (_userScheduleBox != null && _userScheduleBox!.isOpen) {
      await _userScheduleBox!.close();
    }
    _userScheduleBox = null;
    currentUser = null;
  }

  // Generic Storage Methods (Prefixed per user)
  static Future<void> saveData(String key, dynamic data) async {
    if (currentUser == null) return;
    await appBox.put('${currentUser}_$key', data);
  }

  static dynamic getData(String key) {
    if (currentUser == null) return null;
    return appBox.get('${currentUser}_$key');
  }

  // Schedule Specific
  static Future<void> addSchedule(ScheduleModel schedule) async {
    if (_userScheduleBox == null) return;
    await _userScheduleBox!.put(schedule.id, schedule);
  }

  static List<ScheduleModel> getAllSchedules() {
    if (_userScheduleBox == null) return [];
    return _userScheduleBox!.values.toList();
  }

  static Future<void> deleteSchedule(String id) async {
    if (_userScheduleBox == null) return;
    await _userScheduleBox!.delete(id);
  }
}
