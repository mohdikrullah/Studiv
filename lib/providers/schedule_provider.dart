import 'package:flutter/material.dart';
import '../models/schedule_model.dart';
import '../services/local_db_service.dart';
import '../services/notification_service.dart';

class ScheduleProvider with ChangeNotifier {
  List<ScheduleModel> _schedules = [];
  bool _isLoading = false;

  List<ScheduleModel> get schedules => _schedules;
  bool get isLoading => _isLoading;

  void clearData() {
    _schedules = [];
    notifyListeners();
  }

  Future<void> loadSchedules() async {
    if (LocalDbService.currentUser == null) return;
    _isLoading = true;
    notifyListeners();

    // Small delay so shimmer renders at least one frame
    await Future.delayed(const Duration(milliseconds: 600));
    _schedules = LocalDbService.getAllSchedules();

    _isLoading = false;
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

  /// Returns a conflicting schedule if any, or null if no conflict.
  /// Parses "HH:mm - HH:mm" format.
  ScheduleModel? checkConflict(String day, String timeStr, {String? excludeId}) {
    if (timeStr.trim().isEmpty) return null;

    final parsed = _parseTimeRange(timeStr);
    if (parsed == null) return null;
    final (newStart, newEnd) = parsed;

    for (final s in _schedules) {
      if (excludeId != null && s.id == excludeId) continue;
      if (s.day?.toLowerCase() != day.toLowerCase()) continue;
      if (s.time.trim().isEmpty) continue;

      final existing = _parseTimeRange(s.time);
      if (existing == null) continue;
      final (exStart, exEnd) = existing;

      // Overlap check: not (newEnd <= exStart || newStart >= exEnd)
      if (!(newEnd <= exStart || newStart >= exEnd)) {
        return s; // found conflict
      }
    }
    return null;
  }

  /// Parses "HH:mm - HH:mm" → (startMinutes, endMinutes) or null on failure.
  (int, int)? _parseTimeRange(String timeStr) {
    final parts = timeStr.split('-');
    if (parts.length < 2) return null;
    final start = _toMinutes(parts[0].trim());
    final end   = _toMinutes(parts[1].trim());
    if (start == null || end == null) return null;
    return (start, end);
  }

  int? _toMinutes(String t) {
    final hm = t.split(':');
    if (hm.length < 2) return null;
    final h = int.tryParse(hm[0]);
    final m = int.tryParse(hm[1]);
    if (h == null || m == null) return null;
    return h * 60 + m;
  }
}
