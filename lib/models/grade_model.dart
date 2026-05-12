class GradeModel {
  final String id;
  final String name;
  final int sks;
  final String grade;
  final int semester;

  GradeModel({
    required this.id,
    required this.name,
    required this.sks,
    required this.grade,
    required this.semester,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sks': sks,
      'grade': grade,
      'semester': semester,
    };
  }

  factory GradeModel.fromJson(Map<String, dynamic> json) {
    return GradeModel(
      id: json['id'],
      name: json['name'],
      sks: json['sks'],
      grade: json['grade'],
      semester: json['semester'],
    );
  }

  double get gradeValue {
    switch (grade) {
      case 'A': return 4.0;
      case 'A-': return 3.75;
      case 'B+': return 3.5;
      case 'B': return 3.0;
      case 'B-': return 2.75;
      case 'C+': return 2.5;
      case 'C': return 2.0;
      case 'D': return 1.0;
      case 'E': return 0.0;
      default: return 0.0;
    }
  }
}
