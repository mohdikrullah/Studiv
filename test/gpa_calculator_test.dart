import 'package:flutter_test/flutter_test.dart';
import 'package:studiv/utils/gpa_calculator.dart';

void main() {
  group('GPA Calculator Tests', () {
    test('Calculates GPA correctly for a standard semester', () {
      final courses = [
        CourseGrade(credits: 3, grade: 'A'), // 3 * 4 = 12
        CourseGrade(credits: 3, grade: 'B'), // 3 * 3 = 9
        CourseGrade(credits: 2, grade: 'C'), // 2 * 2 = 4
      ];
      // Total points: 25. Total credits: 8.
      // GPA: 25 / 8 = 3.125 -> rounded to 3.13
      
      final gpa = GPACalculator.calculateGPA(courses);
      expect(gpa, 3.13);
    });

    test('Returns 0.0 for an empty course list', () {
      final courses = <CourseGrade>[];
      final gpa = GPACalculator.calculateGPA(courses);
      expect(gpa, 0.0);
    });

    test('Returns 0.0 if all courses have 0 credits', () {
      final courses = [
        CourseGrade(credits: 0, grade: 'A'),
        CourseGrade(credits: 0, grade: 'B'),
      ];
      final gpa = GPACalculator.calculateGPA(courses);
      expect(gpa, 0.0);
    });

    test('Handles lowercase grades correctly', () {
      final courses = [
        CourseGrade(credits: 4, grade: 'a'), // 4 * 4 = 16
        CourseGrade(credits: 2, grade: 'b'), // 2 * 3 = 6
      ];
      // Total points: 22. Total credits: 6.
      // GPA: 22 / 6 = 3.666... -> rounded to 3.67
      
      final gpa = GPACalculator.calculateGPA(courses);
      expect(gpa, 3.67);
    });

    test('Throws error on invalid grade', () {
      final courses = [
        CourseGrade(credits: 3, grade: 'Z'),
      ];
      expect(() => GPACalculator.calculateGPA(courses), throwsArgumentError);
    });

    test('Throws error on negative credits', () {
      final courses = [
        CourseGrade(credits: -2, grade: 'A'),
      ];
      expect(() => GPACalculator.calculateGPA(courses), throwsArgumentError);
    });
  });
}
