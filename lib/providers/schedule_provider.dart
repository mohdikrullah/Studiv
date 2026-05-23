import 'package:flutter/material.dart';
import '../models/schedule_model.dart';
import '../services/local_db_service.dart';

class ScheduleProvider with ChangeNotifier {
  List<ScheduleModel> _schedules = [];

  List<ScheduleModel> get schedules => _schedules;

  void clearData() {
    _schedules = [];
    notifyListeners();
  }

  void loadSchedules() {
    if (LocalDbService.currentUser == null) return;
    _schedules = LocalDbService.getAllSchedules();
    notifyListeners();
  }

  void addSchedule(ScheduleModel schedule) {
    if (LocalDbService.currentUser == null) return;
    LocalDbService.addSchedule(schedule);
    _schedules.add(schedule);
    notifyListeners();
  }

  void deleteSchedule(String id) {
    if (LocalDbService.currentUser == null) return;
    LocalDbService.deleteSchedule(id);
    _schedules.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void updateSchedule(ScheduleModel schedule) {
    if (LocalDbService.currentUser == null) return;
    LocalDbService.addSchedule(schedule); // Hive put replaces if key exists
    int index = _schedules.indexWhere((s) => s.id == schedule.id);
    if (index != -1) {
      _schedules[index] = schedule;
      notifyListeners();
    }
  }
}
