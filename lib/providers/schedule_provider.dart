import 'package:flutter/material.dart';
import '../models/schedule_model.dart';
import '../services/local_db_service.dart';

class ScheduleProvider with ChangeNotifier {
  List<ScheduleModel> _schedules = [];

  List<ScheduleModel> get schedules => _schedules;

  void loadSchedules() {
    _schedules = LocalDbService.getAllSchedules();
    
    // Add dummy data if empty, just to show UI
    if (_schedules.isEmpty) {
      addSchedule(ScheduleModel(
        id: 's1',
        subject: 'Data Structures',
        time: '10:00 AM',
        room: 'Room 402',
      ));
      addSchedule(ScheduleModel(
        id: 's2',
        subject: 'Software Engineering',
        time: '13:00 PM',
        room: 'Lab A',
      ));
    }
    notifyListeners();
  }

  void addSchedule(ScheduleModel schedule) {
    LocalDbService.addSchedule(schedule);
    _schedules.add(schedule);
    notifyListeners();
  }
}
