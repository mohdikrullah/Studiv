import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../models/schedule_model.dart';
import '../../providers/navigation_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ScheduleProvider>(context, listen: false).loadSchedules();
    });
  }

  void _showAddScheduleSheet() {
    final nameController = TextEditingController();
    final roomController = TextEditingController();
    final timeController = TextEditingController();
    final dayController = TextEditingController();
    final lecturerController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                'Tambah Jadwal Baru',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.slateDark,
                ),
              ),
              const SizedBox(height: 24),
              _buildSheetField('Nama Mata Kuliah', nameController, Icons.book_outlined),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildSheetField('Hari', dayController, Icons.calendar_today_outlined)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSheetField('Jam', timeController, Icons.access_time_rounded)),
                ],
              ),
              const SizedBox(height: 16),
              _buildSheetField('Ruangan', roomController, Icons.location_on_outlined),
              const SizedBox(height: 16),
              _buildSheetField('Dosen', lecturerController, Icons.person_outline_rounded),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      final newSchedule = ScheduleModel(
                        id: DateTime.now().toString(),
                        subject: nameController.text,
                        time: timeController.text,
                        room: roomController.text,
                        day: dayController.text,
                        lecturer: lecturerController.text,
                      );
                      Provider.of<ScheduleProvider>(context, listen: false).addSchedule(newSchedule);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Jadwal berhasil ditambahkan!')),
                      );
                    }
                  },
                  child: const Text('Simpan Jadwal'),
                ),
              ),
              const SizedBox(height: 32),
            ],
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
    final user = Provider.of<AuthProvider>(context).user;
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddScheduleSheet,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add_rounded, size: 32, color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'STUDIV',
                      style: GoogleFonts.outfit(
                        color: AppTheme.primaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => navProvider.setIndex(3), // Go to Profile
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                          backgroundImage: user?.profilePicture != null ? NetworkImage(user!.profilePicture!) : null,
                          child: user?.profilePicture == null ? const Icon(Icons.person, color: AppTheme.primaryColor) : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- Sapaan ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, ${user?.fullName != null && user!.fullName!.isNotEmpty ? user.fullName! : (user?.username ?? 'Mahasiswa')} 👋',
                      style: GoogleFonts.inter(fontSize: 14, color: AppTheme.slateGray),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Semangat belajarnya hari ini!',
                      style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.slateDark),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // --- Jadwal Kuliah Section ---
              _buildSectionHeader('Jadwal Kuliah', () {
                navProvider.setIndex(1); // Go to Schedule tab
              }),
              const SizedBox(height: 16),
              SizedBox(
                height: 160,
                child: Consumer<ScheduleProvider>(
                  builder: (context, provider, child) {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 24),
                      physics: const BouncingScrollPhysics(),
                      itemCount: provider.schedules.length,
                      itemBuilder: (context, index) {
                        final schedule = provider.schedules[index];
                        return _buildScheduleCard(schedule);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // --- Tugas Mendesak Section ---
              _buildSectionHeader('Tugas Mendesak', () {
                navProvider.setIndex(2); // Go to Tasks tab
              }),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    _buildUrgentTaskCard(
                      'Final Project Mobile Dev', 
                      'Deadline: Besok, 23:59', 
                      const Color(0xFFFFEFEF), 
                      Colors.redAccent,
                      Icons.warning_amber_rounded
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSmallTaskCard('Quiz AI', '14 Mei', const Color(0xFFF0F4FF), AppTheme.primaryColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSmallTaskCard('Project UI/UX', '16 Mei', const Color(0xFFFFF7E6), Colors.orange),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // --- Progress Kursus Section ---
              _buildSectionHeader('Progress Kursus', null),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    _buildProgressCard('UI/UX Design Masterclass', 0.75, '12/16 Materi Selesai'),
                    const SizedBox(height: 12),
                    _buildProgressCard('Flutter Intermediate Path', 0.40, '6/15 Materi Selesai'),
                  ],
                ),
              ),
              const SizedBox(height: 100), // Spacing for FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback? onAction) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.slateDark),
          ),
          if (onAction != null)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onAction,
                child: Text(
                  'Lihat Semua',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryColor),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(ScheduleModel schedule) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              schedule.time,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
            ),
          ),
          const Spacer(),
          Text(
            schedule.subject,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.slateDark),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.slateGray),
              const SizedBox(width: 4),
              Text(
                schedule.room,
                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.slateGray),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentTaskCard(String title, String deadline, Color bg, Color accent, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.slateDark)),
                const SizedBox(height: 4),
                Text(deadline, style: GoogleFonts.inter(fontSize: 12, color: accent, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallTaskCard(String title, String date, Color bg, Color accent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.slateDark)),
          const SizedBox(height: 4),
          Text(date, style: GoogleFonts.inter(fontSize: 12, color: accent, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildProgressCard(String title, double progress, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.slateDark)),
              Text('${(progress * 100).toInt()}%', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
          const SizedBox(height: 12),
          Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.slateGray)),
        ],
      ),
    );
  }
}
