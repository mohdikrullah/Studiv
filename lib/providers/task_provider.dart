import 'package:flutter/material.dart';
import '../models/task_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskProvider with ChangeNotifier {
  List<TaskModel> _tasks = [];
  bool _isLoading = false;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;

  int get completedTasksCount => _tasks.where((t) => t.status == 'Done').length;
  int get totalTasksCount => _tasks.length;

  // Simulate fetching tasks for now, since we haven't configured google-services.json
  // When Firestore is fully configured, this will listen to Firebase snapshots.
  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners();

    // Simulated network delay
    await Future.delayed(const Duration(seconds: 1));

    // Dummy data until Firestore is connected
    _tasks = [
      TaskModel(id: '1', title: 'Math Assignment', status: 'Done'),
      TaskModel(id: '2', title: 'Read Chapter 4', status: 'To-Do'),
      TaskModel(id: '3', title: 'Project Proposal', status: 'In Progress'),
    ];

    _isLoading = false;
    notifyListeners();
  }

  void addTask(TaskModel task) {
    _tasks.add(task);
    notifyListeners();
    // TODO: Add to Firestore
  }
}
