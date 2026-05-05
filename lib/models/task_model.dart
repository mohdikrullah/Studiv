class TaskModel {
  String id;
  String title;
  String description;
  String status; // 'To-Do', 'In Progress', 'Done'
  DateTime? dueDate;

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    this.status = 'To-Do',
    this.dueDate,
  });

  // Factory to create from Map (Firestore)
  factory TaskModel.fromMap(Map<String, dynamic> data, String documentId) {
    return TaskModel(
      id: documentId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'To-Do',
      dueDate: data['dueDate'] != null ? DateTime.parse(data['dueDate'].toString()) : null,
    );
  }

  // Convert to Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'dueDate': dueDate?.toIso8601String(),
    };
  }
}
