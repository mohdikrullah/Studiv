import 'package:flutter/material.dart';
import '../models/task_model.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class TaskProvider with ChangeNotifier {
  List<TaskModel> _tasks = [];
  bool _isLoading = false;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;

  int get completedTasksCount => _tasks.where((t) => t.status == 'Done').length;
  int get totalTasksCount => _tasks.length;

  // Simulate fetching tasks for now
  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners();

    // Simulated network delay
    await Future.delayed(const Duration(seconds: 1));

    // Dummy data until Firestore is connected
    if (_tasks.isEmpty) {
      _tasks = [
        TaskModel(
          id: '1', 
          title: 'Tugas Matematika', 
          status: 'Done', 
          description: 'Halaman 42-45',
          dueDate: DateTime.now().subtract(const Duration(days: 2)),
        ),
        TaskModel(
          id: '2', 
          title: 'Baca Bab 4', 
          status: 'To-Do', 
          description: 'Persiapan UTS',
          dueDate: DateTime.now().add(const Duration(days: 3)),
        ),
        TaskModel(
          id: '3', 
          title: 'Proposal Proyek', 
          status: 'In Progress', 
          description: 'Draft kasar bab 1-3',
          dueDate: DateTime.now().add(const Duration(days: 7)),
        ),
      ];
    }

    _isLoading = false;
    notifyListeners();
  }

  void addTask(TaskModel task) {
    _tasks.add(task);
    notifyListeners();
    // TODO: Add to Firestore
  }

  void updateTask(TaskModel task) {
    int index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
      // TODO: Update in Firestore
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
    // TODO: Delete from Firestore
  }
}
