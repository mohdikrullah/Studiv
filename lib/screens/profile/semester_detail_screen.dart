import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../utils/navigation_utils.dart';

import 'package:provider/provider.dart';
import '../../providers/grade_provider.dart';
import '../../models/grade_model.dart';

class SemesterDetailScreen extends StatefulWidget {
  final int semesterNumber;

  const SemesterDetailScreen({
    super.key,
    required this.semesterNumber,
  });

  @override
  State<SemesterDetailScreen> createState() => _SemesterDetailScreenState();
}

class _SemesterDetailScreenState extends State<SemesterDetailScreen> {
  void _showAddGradeSheet({GradeModel? editGrade}) {
    final nameController = TextEditingController(text: editGrade?.name);
    final sksController = TextEditingController(text: editGrade?.sks.toString());
    String selectedGrade = editGrade?.grade ?? 'A';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  editGrade == null ? 'Tambah Mata Kuliah' : 'Edit Mata Kuliah',
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.slateDark),
                ),
                const SizedBox(height: 24),
                _buildSheetField('Nama Mata Kuliah', nameController, Icons.book_outlined),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SKS', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.slateGray)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: sksController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Contoh: 3',
                        prefixIcon: Icon(Icons.numbers_rounded, size: 20, color: AppTheme.primaryColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Nilai', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.slateGray)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.slateLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedGrade,
                      isExpanded: true,
                      items: ['A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'D', 'E']
                          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedGrade = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty && sksController.text.isNotEmpty) {
                        if (editGrade == null) {
                          final newGrade = GradeModel(
                            id: DateTime.now().toString(),
                            name: nameController.text,
                            sks: int.tryParse(sksController.text) ?? 2,
                            grade: selectedGrade,
                            semester: widget.semesterNumber,
                          );
                          Provider.of<GradeProvider>(context, listen: false).addGrade(newGrade);
                        } else {
                          final updatedGrade = GradeModel(
                            id: editGrade.id,
                            name: nameController.text,
                            sks: int.tryParse(sksController.text) ?? 2,
                            grade: selectedGrade,
                            semester: widget.semesterNumber,
                          );
                          Provider.of<GradeProvider>(context, listen: false).updateGrade(updatedGrade);
                        }
                        Navigator.pop(context);
                      }
                    },
                    child: Text(editGrade == null ? 'Simpan Mata Kuliah' : 'Perbarui Mata Kuliah'),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSheetField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.slateGray)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Masukkan $label',
            prefixIcon: Icon(icon, size: 20, color: AppTheme.primaryColor),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradeProvider = Provider.of<GradeProvider>(context);
    final courses = gradeProvider.getGradesBySemester(widget.semesterNumber);
    final ips = gradeProvider.calculateIPS(widget.semesterNumber);
    final totalSks = courses.fold(0, (sum, item) => sum + item.sks);

    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvoked: (didPop) {
        if (!didPop && Navigator.canPop(context)) {
          Navigator.pop(context);
        } else if (!didPop) {
          NavigationUtils.safeBack(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text(
            'Semester ${widget.semesterNumber}',
            style: GoogleFonts.outfit(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          leading: buildSafeBackButton(
            context,
            color: AppTheme.slateDark,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddGradeSheet,
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.add_rounded, size: 32, color: Colors.white),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatBox('IPS', ips.toStringAsFixed(2), AppTheme.primaryColor),
                const SizedBox(width: 16),
                _buildStatBox('SKS', totalSks.toString(), Colors.orange),
                const SizedBox(width: 16),
                _buildStatBox('Matkul', courses.length.toString(), Colors.green),
              ],
            ),
            
            const SizedBox(height: 32),
            Text(
              'Daftar Mata Kuliah',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.slateDark,
              ),
            ),
            const SizedBox(height: 16),
            
            if (courses.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    children: [
                      Icon(Icons.book_rounded, size: 64, color: AppTheme.slateGray.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada mata kuliah',
                        style: GoogleFonts.inter(color: AppTheme.slateGray),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return _buildCourseCard(context, course);
                },
              ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.softShadow,
          border: Border.all(color: color.withOpacity(0.1), width: 1),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.slateGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, GradeModel course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                course.grade,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: InkWell(
              onTap: () => _showAddGradeSheet(editGrade: course),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.name,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.slateDark,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${course.sks} SKS',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.slateGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
            onPressed: () {
              Provider.of<GradeProvider>(context, listen: false).removeGrade(course.id);
            },
          ),
        ],
      ),
    );
  }
}
