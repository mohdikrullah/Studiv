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
        subject: 'Struktur Data',
        time: '10:00',
        room: 'Ruang 402',
      ));
      addSchedule(ScheduleModel(
        id: 's2',
        subject: 'Rekayasa Perangkat Lunak',
        time: '13:00',
        room: 'Lab Komputer A',
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
