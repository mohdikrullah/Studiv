import 'package:flutter/material.dart';
import '../models/schedule_model.dart';
import '../services/local_db_service.dart';
import '../services/notification_service.dart';

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

  Future<void> addSchedule(ScheduleModel schedule) async {
    if (LocalDbService.currentUser == null) return;
    LocalDbService.addSchedule(schedule);
    _schedules.add(schedule);
    await NotificationService.scheduleClassReminder(schedule);
    notifyListeners();
  }

  Future<void> deleteSchedule(String id) async {
    if (LocalDbService.currentUser == null) return;
    LocalDbService.deleteSchedule(id);
    _schedules.removeWhere((s) => s.id == id);
    await NotificationService.cancelReminder(id);
    notifyListeners();
  }

  Future<void> updateSchedule(ScheduleModel schedule) async {
    if (LocalDbService.currentUser == null) return;
    LocalDbService.addSchedule(schedule);
    int index = _schedules.indexWhere((s) => s.id == schedule.id);
    if (index != -1) {
      _schedules[index] = schedule;
      await NotificationService.cancelReminder(_schedules[index].id);
      await NotificationService.scheduleClassReminder(schedule);
      notifyListeners();
    }
  }
}
