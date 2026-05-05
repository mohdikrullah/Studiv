class CourseGrade {
  final int credits; // SKS
  final String grade; // A, B, C, D, E

  CourseGrade({required this.credits, required this.grade});
}

class GPACalculator {
  static final Map<String, double> _gradeWeights = {
    'A': 4.0,
    'B': 3.0,
    'C': 2.0,
    'D': 1.0,
    'E': 0.0,
  };

  /// Calculates the GPA given a list of [CourseGrade].
  /// Returns 0.0 if the list is empty or total credits is 0.
  static double calculateGPA(List<CourseGrade> courses) {
    if (courses.isEmpty) return 0.0;

    int totalCredits = 0;
    double totalPoints = 0.0;

    for (var course in courses) {
      if (course.credits < 0) {
         throw ArgumentError('Credits cannot be negative');
      }
      
      final weight = _gradeWeights[course.grade.toUpperCase()];
      if (weight == null) {
        throw ArgumentError('Invalid grade: ${course.grade}');
      }

      totalCredits += course.credits;
      totalPoints += (weight * course.credits);
    }

    if (totalCredits == 0) return 0.0;

    // Round to 2 decimal places
    double gpa = totalPoints / totalCredits;
    return double.parse(gpa.toStringAsFixed(2));
  }
}
