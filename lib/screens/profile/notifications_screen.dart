import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _taskReminder = true;
  bool _scheduleAlert = true;
  bool _examNotice = true;
  bool _academicUpdate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'NOTIFIKASI',
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
            _buildSectionTitle('Pengaturan Notifikasi'),
            const SizedBox(height: 16),
            _buildSwitchTile(
              'Pengingat Tugas',
              'Dapatkan notifikasi sebelum tugas berakhir',
              Icons.assignment_outlined,
              _taskReminder,
              (val) => setState(() => _taskReminder = val),
            ),
            _buildSwitchTile(
              'Jadwal Kuliah',
              'Notifikasi 15 menit sebelum kuliah dimulai',
              Icons.calendar_today_outlined,
              _scheduleAlert,
              (val) => setState(() => _scheduleAlert = val),
            ),
            _buildSwitchTile(
              'Pengumuman Ujian',
              'Informasi penting terkait jadwal ujian',
              Icons.notification_important_outlined,
              _examNotice,
              (val) => setState(() => _examNotice = val),
            ),
            _buildSwitchTile(
              'Pembaruan Akademik',
              'Info nilai baru atau perubahan kurikulum',
              Icons.school_outlined,
              _academicUpdate,
              (val) => setState(() => _academicUpdate = val),
            ),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Notifikasi Terbaru'),
            const SizedBox(height: 16),
            _buildNotificationItem(
              'Tugas Mendesak!',
              'Tugas Matematika Diskrit akan berakhir dalam 2 jam.',
              '2j yang lalu',
              Icons.warning_amber_rounded,
              Colors.orange,
            ),
            _buildNotificationItem(
              'Kuliah Dimulai',
              'Basis Data di Ruang R.302 dimulai dalam 15 menit.',
              '5j yang lalu',
              Icons.access_time_rounded,
              AppTheme.primaryColor,
            ),
            _buildNotificationItem(
              'Nilai Keluar',
              'Nilai mata kuliah Algoritma Semester 3 telah dirilis.',
              'Kemarin',
              Icons.grade_outlined,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppTheme.slateGray,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.slateDark),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.slateGray),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String desc, String time, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppTheme.slateDark),
                    ),
                    Text(
                      time,
                      style: GoogleFonts.inter(fontSize: 10, color: AppTheme.slateGray),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: GoogleFonts.inter(fontSize: 12, color: AppTheme.slateGray, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
