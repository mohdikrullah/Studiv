import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/grade_provider.dart';
import 'semester_detail_screen.dart';

class AcademicHistoryScreen extends StatelessWidget {
  const AcademicHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gradeProvider = Provider.of<GradeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final currentSemester = user?.semester ?? 1;
    
    final ipk = gradeProvider.calculateIPK();
    final totalSks = gradeProvider.calculateTotalSKS();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'RIWAYAT AKADEMIK',
          style: GoogleFonts.outfit(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.slateDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GPA Summary Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'IPK Kumulatif',
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ipk.toStringAsFixed(2),
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.trending_up_rounded, color: Colors.white, size: 32),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryInfo('Total SKS', totalSks.toString()),
                      _buildSummaryInfo('Semester', currentSemester.toString()), // Dynamic based on user
                      _buildSummaryInfo('Predikat', ipk >= 3.5 ? 'Pujian' : (ipk >= 3.0 ? 'Sangat Memuaskan' : 'Memuaskan')),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            Text(
              'Detail Semester',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.slateDark,
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            ...List.generate(currentSemester, (index) {
              final semesterNum = currentSemester - index;
              return _buildSemesterCard(context, semesterNum, gradeProvider, currentSemester);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
        Text(
          value,
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildSemesterCard(BuildContext context, int semesterNumber, GradeProvider provider, int currentSemester) {
    final ips = provider.calculateIPS(semesterNumber);
    final sks = provider.getGradesBySemester(semesterNumber).fold(0, (sum, item) => sum + item.sks);
    final isCurrent = semesterNumber == currentSemester;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SemesterDetailScreen(
                  semesterNumber: semesterNumber,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: isCurrent ? Border.all(color: AppTheme.primaryColor.withOpacity(0.3), width: 1) : null,
              boxShadow: AppTheme.softShadow,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.class_outlined, color: AppTheme.primaryColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Semester $semesterNumber',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppTheme.slateDark),
                      ),
                      Text(
                        '$sks SKS',
                        style: GoogleFonts.inter(fontSize: 12, color: AppTheme.slateGray),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      ips.toStringAsFixed(2),
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Text(
                      'IPS',
                      style: GoogleFonts.inter(fontSize: 10, color: AppTheme.slateGray, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, color: AppTheme.slateGray),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
