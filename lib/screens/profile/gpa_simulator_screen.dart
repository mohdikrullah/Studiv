import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/grade_provider.dart';
import '../../utils/navigation_utils.dart';

class _SimCourse {
  String name;
  int sks;
  String grade;
  _SimCourse({required this.name, required this.sks, required this.grade});
}

double _gradeToPoint(String g) {
  switch (g) {
    case 'A':  return 4.00;
    case 'A-': return 3.75;
    case 'B+': return 3.50;
    case 'B':  return 3.00;
    case 'B-': return 2.75;
    case 'C+': return 2.50;
    case 'C':  return 2.00;
    case 'D':  return 1.00;
    case 'E':  return 0.00;
    default:   return 0.00;
  }
}

class GpaSimulatorScreen extends StatefulWidget {
  const GpaSimulatorScreen({super.key});

  @override
  State<GpaSimulatorScreen> createState() => _GpaSimulatorScreenState();
}

class _GpaSimulatorScreenState extends State<GpaSimulatorScreen> {
  final List<_SimCourse> _courses = [];
  final _targetController = TextEditingController(text: '3.50');

  static const List<String> _grades = ['A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'D', 'E'];

  // Computed values
  double _calcSimGpa(double currentIPK, int currentSKS) {
    if (_courses.isEmpty) return currentIPK;
    double totalPoints = currentIPK * currentSKS;
    int totalSKS = currentSKS;
    for (final c in _courses) {
      totalPoints += _gradeToPoint(c.grade) * c.sks;
      totalSKS += c.sks;
    }
    return totalSKS == 0 ? 0 : totalPoints / totalSKS;
  }

  void _addCourse() {
    setState(() {
      _courses.add(_SimCourse(name: 'Matakuliah ${_courses.length + 1}', sks: 3, grade: 'A'));
    });
  }

  void _removeCourse(int index) {
    setState(() => _courses.removeAt(index));
  }

  Color _gpaColor(double gpa) {
    if (gpa >= 3.5) return Colors.green;
    if (gpa >= 3.0) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final gradeProvider = Provider.of<GradeProvider>(context, listen: false);
    final currentIPK = gradeProvider.calculateIPK();
    final currentSKS = gradeProvider.calculateTotalSKS();
    final simIPK = _calcSimGpa(currentIPK, currentSKS);
    final diff = simIPK - currentIPK;
    final target = double.tryParse(_targetController.text) ?? 3.5;
    final targetReachable = simIPK >= target;

    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvoked: (didPop) {
        if (!didPop && Navigator.canPop(context)) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text(
            'SIMULATOR IPK',
            style: GoogleFonts.outfit(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          leading: buildSafeBackButton(context, color: AppTheme.slateDark),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Comparison Card ───
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF9C8FFF)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: Row(
                  children: [
                    Expanded(child: _gpaBox('IPK Saat Ini', currentIPK, Colors.white70)),
                    Container(width: 1, height: 60, color: Colors.white30),
                    Expanded(child: _gpaBox(
                      'IPK Simulasi',
                      simIPK,
                      _courses.isEmpty ? Colors.white70 : (diff >= 0 ? Colors.greenAccent : Colors.redAccent),
                      suffix: _courses.isEmpty ? '' : (diff >= 0 ? ' ▲' : ' ▼'),
                      diffText: _courses.isEmpty ? '' : '${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(2)}',
                    )),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ─── Target IPK Input ───
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🎯 Target IPK Kumulatif',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.slateDark)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _targetController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(hintText: 'Contoh: 3.50'),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: targetReachable ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                targetReachable ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                color: targetReachable ? Colors.green : Colors.red,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                targetReachable ? 'Tercapai!' : 'Belum',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: targetReachable ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (!targetReachable && _courses.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, color: Colors.orange, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tambahkan lebih banyak mata kuliah dengan nilai tinggi untuk mencapai target.',
                                style: GoogleFonts.inter(fontSize: 11, color: Colors.orange[800]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── Simulation Courses ───
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mata Kuliah Simulasi',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.slateDark),
                  ),
                  TextButton.icon(
                    onPressed: _addCourse,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text('Tambah', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (_courses.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.slateLight, width: 1.5),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.science_outlined, size: 48, color: AppTheme.slateGray.withOpacity(0.4)),
                        const SizedBox(height: 12),
                        Text('Belum ada simulasi', style: GoogleFonts.inter(color: AppTheme.slateGray)),
                        const SizedBox(height: 4),
                        Text(
                          'Tekan "+ Tambah" untuk mulai simulasi nilai',
                          style: GoogleFonts.inter(fontSize: 12, color: AppTheme.slateGray.withOpacity(0.7)),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...List.generate(_courses.length, (i) => _buildCourseRow(i)),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gpaBox(String label, double value, Color valueColor, {String suffix = '', String diffText = ''}) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value.toStringAsFixed(2),
              style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            if (suffix.isNotEmpty)
              Text(suffix, style: GoogleFonts.inter(fontSize: 14, color: valueColor, fontWeight: FontWeight.bold)),
          ],
        ),
        if (diffText.isNotEmpty)
          Text(diffText, style: GoogleFonts.inter(fontSize: 12, color: valueColor, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCourseRow(int index) {
    final course = _courses[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _gpaColor(_gradeToPoint(course.grade)).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  course.grade,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: _gpaColor(_gradeToPoint(course.grade)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  course.name,
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppTheme.slateDark),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18, color: Colors.redAccent),
                onPressed: () => _removeCourse(index),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // SKS Stepper
              Text('SKS:', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.slateGray, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              _buildStepper(
                value: course.sks,
                onDecrement: () { if (course.sks > 1) setState(() => course.sks--); },
                onIncrement: () { if (course.sks < 6) setState(() => course.sks++); },
              ),
              const SizedBox(width: 16),
              // Grade Selector
              Text('Nilai:', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.slateGray, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: AppTheme.slateLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: course.grade,
                    dropdownColor: AppTheme.cardColor,
                    items: _grades.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: (val) { if (val != null) setState(() => course.grade = val); },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepper({required int value, required VoidCallback onDecrement, required VoidCallback onIncrement}) {
    return Row(
      children: [
        InkWell(
          onTap: onDecrement,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: AppTheme.slateLight, borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.remove_rounded, size: 16, color: AppTheme.slateDark),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('$value', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.slateDark)),
        ),
        InkWell(
          onTap: onIncrement,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: AppTheme.slateLight, borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.add_rounded, size: 16, color: AppTheme.slateDark),
          ),
        ),
      ],
    );
  }
}
