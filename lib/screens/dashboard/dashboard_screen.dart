import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../models/schedule_model.dart';
import '../../widgets/studiv_app_bar.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task_model.dart';
import 'package:intl/intl.dart';

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
      Provider.of<TaskProvider>(context, listen: false).fetchTasks();
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi ☀️';
    if (hour < 15) return 'Selamat Siang 🌤️';
    if (hour < 18) return 'Selamat Sore 🌅';
    return 'Selamat Malam 🌙';
  }

  String _getTodayDayName() {
    const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    return days[DateTime.now().weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
    final displayName = (user?.fullName != null && user!.fullName!.isNotEmpty)
        ? user.fullName!
        : (user?.username ?? 'Mahasiswa');
    final todayDay = _getTodayDayName();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),
      appBar: StudivAppBar(
        hasNotif: true,
        onNotifTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak ada notifikasi baru'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ═══════════════════════════════════════
              // HERO GRADIENT BANNER
              // ═══════════════════════════════════════
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF9C8FFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting & Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(),
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              displayName,
                              style: GoogleFonts.outfit(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            DateFormat('d MMM y').format(DateTime.now()),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Divider(color: Colors.white24, height: 1),
                    const SizedBox(height: 20),

                    // Quick Stats
                    Consumer2<ScheduleProvider, TaskProvider>(
                      builder: (context, schedProv, taskProv, child) {
                        final todaySchedules = schedProv.schedules
                            .where((s) => s.day?.trim().toLowerCase() == todayDay.toLowerCase())
                            .length;
                        final activeTasks = taskProv.tasks.where((t) => t.status != 'Done').length;
                        final doneTasks = taskProv.completedTasksCount;

                        return Row(
                          children: [
                            _buildStatPill(Icons.calendar_today_rounded, '$todaySchedules', 'Jadwal\nHari Ini'),
                            const SizedBox(width: 12),
                            _buildStatPill(Icons.assignment_outlined, '$activeTasks', 'Tugas\nAktif'),
                            const SizedBox(width: 12),
                            _buildStatPill(Icons.check_circle_outline_rounded, '$doneTasks', 'Tugas\nSelesai'),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ═══════════════════════════════════════
              // JADWAL KULIAH HARI INI
              // ═══════════════════════════════════════
              _buildSectionHeader('Jadwal Kuliah Hari Ini', () => navProvider.setIndex(1)),
              const SizedBox(height: 14),
              SizedBox(
                height: 160,
                child: Consumer<ScheduleProvider>(
                  builder: (context, provider, child) {
                    final todaySchedules = provider.schedules
                        .where((s) => s.day?.trim().toLowerCase() == todayDay.toLowerCase())
                        .toList();

                    if (todaySchedules.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildEmptyState(
                          Icons.event_available_rounded,
                          'Tidak ada jadwal hari ini',
                          'Tambah di menu Jadwal 📅',
                          onTap: () => navProvider.setIndex(1),
                        ),
                      );
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 16),
                      physics: const BouncingScrollPhysics(),
                      itemCount: todaySchedules.length,
                      itemBuilder: (context, index) => _buildScheduleCard(todaySchedules[index]),
                    );
                  },
                ),
              ),

              const SizedBox(height: 28),

              // ═══════════════════════════════════════
              // TUGAS MENDESAK
              // ═══════════════════════════════════════
              _buildSectionHeader('Tugas Mendesak', () => navProvider.setIndex(2)),
              const SizedBox(height: 14),
              Consumer<TaskProvider>(
                builder: (context, taskProvider, child) {
                  final activeTasks = taskProvider.tasks
                      .where((t) => t.status != 'Done')
                      .toList();

                  activeTasks.sort((a, b) {
                    if (a.dueDate == null && b.dueDate == null) return 0;
                    if (a.dueDate == null) return 1;
                    if (b.dueDate == null) return -1;
                    return a.dueDate!.compareTo(b.dueDate!);
                  });

                  if (activeTasks.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildEmptyState(
                        Icons.check_circle_rounded,
                        'Semua tugas sudah selesai!',
                        'Tambah tugas baru di menu Tugas ✅',
                        accentColor: Colors.green,
                        onTap: () => navProvider.setIndex(2),
                      ),
                    );
                  }

                  final formatter = DateFormat('dd MMM');
                  final timeFormatter = DateFormat('HH:mm');

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Primary urgent task
                        _buildUrgentTaskCard(activeTasks[0], formatter, timeFormatter),

                        // Secondary tasks (2 columns)
                        if (activeTasks.length > 1) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildSmallTaskCard(
                                  activeTasks[1],
                                  formatter,
                                  const Color(0xFFEEF0FF),
                                  AppTheme.primaryColor,
                                ),
                              ),
                              if (activeTasks.length > 2) ...[
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildSmallTaskCard(
                                    activeTasks[2],
                                    formatter,
                                    const Color(0xFFFFF4E6),
                                    Colors.orange,
                                  ),
                                ),
                              ] else
                                const Spacer(),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 28),

              // ═══════════════════════════════════════
              // PROGRESS TUGAS
              // ═══════════════════════════════════════
              _buildSectionHeader('Progress Tugas', null),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Consumer<TaskProvider>(
                  builder: (context, taskProvider, child) {
                    final total = taskProvider.totalTasksCount;
                    final completed = taskProvider.completedTasksCount;
                    final double progress = total == 0 ? 0.0 : completed / total;
                    return _buildProgressCard(progress, completed, total);
                  },
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────
  // HELPER WIDGETS
  // ───────────────────────────────────────

  Widget _buildStatPill(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.3)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback? onAction) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.slateDark)),
          if (onAction != null)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onAction,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Lihat Semua',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String subtitle,
      {Color accentColor = AppTheme.primaryColor, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accentColor.withValues(alpha: 0.15)),
          boxShadow: AppTheme.softShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 26),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.slateDark)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppTheme.slateGray)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(ScheduleModel schedule) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF9C8FFF)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              schedule.time.isNotEmpty ? schedule.time : '—',
              style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const Spacer(),
          Text(
            schedule.subject,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.slateDark),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 13, color: AppTheme.slateGray),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  schedule.room.isNotEmpty ? schedule.room : 'Ruang —',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                      fontSize: 11, color: AppTheme.slateGray),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentTaskCard(
      TaskModel task, DateFormat formatter, DateFormat timeFormatter) {
    String deadline = 'Tanpa Deadline';
    Color accentColor = AppTheme.slateGray;
    Color bgColor = const Color(0xFFF5F5F5);

    if (task.dueDate != null) {
      final now = DateTime.now();
      final diff = task.dueDate!.difference(now).inDays;
      if (diff < 0) {
        deadline = 'Terlambat! ${formatter.format(task.dueDate!)}';
        accentColor = Colors.red;
        bgColor = const Color(0xFFFFEEEE);
      } else if (diff == 0) {
        deadline = 'Hari ini, ${timeFormatter.format(task.dueDate!)}';
        accentColor = Colors.red;
        bgColor = const Color(0xFFFFEFEF);
      } else if (diff == 1) {
        deadline = 'Besok, ${timeFormatter.format(task.dueDate!)}';
        accentColor = Colors.orange;
        bgColor = const Color(0xFFFFF6EE);
      } else {
        deadline = formatter.format(task.dueDate!);
        accentColor = AppTheme.primaryColor;
        bgColor = const Color(0xFFEEF0FF);
      }
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Icon(Icons.warning_amber_rounded, color: accentColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.slateDark),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 12, color: accentColor),
                    const SizedBox(width: 4),
                    Text(
                      deadline,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: accentColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallTaskCard(
      TaskModel task, DateFormat formatter, Color bgColor, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.assignment_outlined, size: 18, color: accentColor),
          const SizedBox(height: 8),
          Text(
            task.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.slateDark),
          ),
          const SizedBox(height: 4),
          Text(
            task.dueDate != null ? formatter.format(task.dueDate!) : 'No Date',
            style: GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.w600, color: accentColor),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(double progress, int completed, int total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          // Circular Progress
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 7,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Text(
                    '${(progress * 100).toInt()}%',
                    style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tingkat Penyelesaian',
                    style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.slateDark)),
                const SizedBox(height: 6),
                Text(
                  total == 0
                      ? 'Belum ada tugas ditambahkan'
                      : '$completed dari $total tugas selesai',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppTheme.slateGray),
                ),
                if (total > 0) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor:
                          AppTheme.primaryColor.withValues(alpha: 0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryColor),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
