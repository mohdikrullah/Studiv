import 'package:flutter/material.dart';
import '../models/grade_model.dart';
import '../services/local_db_service.dart';

class GradeProvider with ChangeNotifier {
  List<GradeModel> _grades = [];

  List<GradeModel> get grades => _grades;

  List<GradeModel> getGradesBySemester(int semester) {
    return _grades.where((g) => g.semester == semester).toList();
  }

  double calculateIPS(int semester) {
    final semesterGrades = getGradesBySemester(semester);
    if (semesterGrades.isEmpty) return 0.0;

    double totalPoints = 0;
    int totalSKS = 0;

    for (var grade in semesterGrades) {
      totalPoints += (grade.gradeValue * grade.sks);
      totalSKS += grade.sks;
    }

    return totalSKS == 0 ? 0.0 : totalPoints / totalSKS;
  }

  double calculateIPK() {
    if (_grades.isEmpty) return 0.0;

    double totalPoints = 0;
    int totalSKS = 0;

    for (var grade in _grades) {
      totalPoints += (grade.gradeValue * grade.sks);
      totalSKS += grade.sks;
    }

    return totalSKS == 0 ? 0.0 : totalPoints / totalSKS;
  }

  int calculateTotalSKS() {
    return _grades.fold(0, (sum, item) => sum + item.sks);
  }

  Future<void> loadGrades() async {
    final data = LocalDbService.getData('grades');
    if (data != null) {
      _grades = (data as List).map((item) => GradeModel.fromJson(Map<String, dynamic>.from(item))).toList();
      notifyListeners();
    }
  }

  Future<void> addGrade(GradeModel grade) async {
    _grades.add(grade);
    await _saveToDisk();
    notifyListeners();
  }

  Future<void> removeGrade(String id) async {
    _grades.removeWhere((g) => g.id == id);
    await _saveToDisk();
    notifyListeners();
  }

  Future<void> _saveToDisk() async {
    final data = _grades.map((g) => g.toJson()).toList();
    await LocalDbService.saveData('grades', data);
  }
}
