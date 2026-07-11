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
import '../../widgets/shimmer_loading.dart';

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
      backgroundColor: AppTheme.backgroundColor,
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
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryLight,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: AppTheme.softShadow,
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
              Consumer<ScheduleProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const SizedBox(
                      height: 175,
                      child: ScheduleCardSkeleton(),
                    );
                  }

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

                  final List<Widget> rows = [];
                  int startIndex = 0;
                  
                  // Jika ganjil, item pertama full-width
                  if (todaySchedules.length % 2 != 0) {
                    rows.add(_buildScheduleCard(todaySchedules[0]));
                    startIndex = 1;
                  }
                  
                  // Sisanya dipasang berdampingan (2 per baris)
                  for (int i = startIndex; i < todaySchedules.length; i += 2) {
                    if (i > 0) {
                      rows.add(const SizedBox(height: 12));
                    }
                    
                    if (i + 1 < todaySchedules.length) {
                      rows.add(
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildScheduleCard(todaySchedules[i])),
                            const SizedBox(width: 12),
                            Expanded(child: _buildScheduleCard(todaySchedules[i+1])),
                          ],
                        )
                      );
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: rows,
                    ),
                  );
                },
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
              const SizedBox(height: 28),

              _buildSectionHeader('Motivasi Hari Ini', null),

              const SizedBox(height: 14),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildMotivationCard(),
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.2,
              ),
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
          color: AppTheme.cardColor,
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

  Widget _buildScheduleStatusBadge(String timeStr) {
    String status = 'Akan Dimulai';
    Color color = AppTheme.slateGray;
    Color bgColor = AppTheme.slateGray.withValues(alpha: 0.1);

    if (timeStr.isNotEmpty) {
      try {
        final parts = timeStr.split('-');
        final startPart = parts[0].trim();
        final endPart = parts.length > 1 ? parts[1].trim() : '';

        final now = DateTime.now();
        DateTime? startTime;
        DateTime? endTime;

        if (startPart.contains(':')) {
          final startSplit = startPart.split(':');
          startTime = DateTime(now.year, now.month, now.day, int.parse(startSplit[0]), int.parse(startSplit[1]));
        }
        if (endPart.contains(':')) {
          final endSplit = endPart.split(':');
          endTime = DateTime(now.year, now.month, now.day, int.parse(endSplit[0]), int.parse(endSplit[1]));
        }

        if (startTime != null) {
          if (now.isBefore(startTime)) {
            status = 'Akan Dimulai';
            color = AppTheme.slateGray;
            bgColor = AppTheme.slateGray.withValues(alpha: 0.1);
          } else {
            final effectiveEndTime = endTime ?? startTime.add(const Duration(hours: 2));
            if (now.isAfter(effectiveEndTime)) {
              status = 'Selesai';
              color = Colors.green;
              bgColor = Colors.green.withValues(alpha: 0.1);
            } else {
              status = 'Sedang Berlangsung';
              color = AppTheme.primaryColor;
              bgColor = AppTheme.primaryColor.withValues(alpha: 0.1);
            }
          }
        }
      } catch (_) {}
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildScheduleCard(ScheduleModel schedule) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.slateGray.withValues(alpha: 0.1)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      color: AppTheme.primaryColor,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      schedule.time.isNotEmpty ? schedule.time : '--:--',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              _buildScheduleStatusBadge(schedule.time),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            schedule.subject,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.2,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : AppTheme.slateDark),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on_rounded,
                  size: 14, color: AppTheme.slateGray),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  schedule.room.isNotEmpty ? schedule.room : 'Ruang —',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppTheme.slateGray),
                ),
              ),
            ],
          ),
          if (schedule.lecturer != null && schedule.lecturer!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person_rounded,
                    size: 14, color: AppTheme.slateGray),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    schedule.lecturer!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppTheme.slateGray),
                  ),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }

  // Helper: Hitung sisa waktu dalam jam hingga deadline
  // Negatif = sudah terlambat
  double _hoursUntilDeadline(DateTime? dueDate) {
    if (dueDate == null) return double.infinity;
    return dueDate.difference(DateTime.now()).inMinutes / 60.0;
  }

  // Helper: Dapatkan badge teks berdasarkan sisa jam
  String _getDeadlineBadgeFromHours(double hours) {
    if (hours < 0) return 'Terlambat';
    if (hours < 24) return 'Hari Ini';
    if (hours < 48) return 'Besok';
    final days = hours ~/ 24;
    return '$days Hari Lagi';
  }

  // Helper: Dapatkan warna berdasarkan sisa jam
  // < 0: Merah (terlambat), < 24 jam: Merah, H-1 (24-48 jam): Kuning, lainnya: Primary
  Color _getDeadlineAccentColor(double hours) {
    if (hours < 0) return Colors.red;        // Terlambat
    if (hours < 24) return Colors.red;       // Kurang dari 24 jam → MERAH
    if (hours < 48) return const Color(0xFFEAB308); // H-1 (24-48 jam) → KUNING
    return AppTheme.primaryColor;            // H-2+ → Primary (ungu app)
  }

  Color _getDeadlineBgColor(double hours) {
    return _getDeadlineAccentColor(hours).withValues(alpha: 0.06);
  }

  Widget _buildUrgentTaskCard(
      TaskModel task, DateFormat formatter, DateFormat timeFormatter) {
    final hours = _hoursUntilDeadline(task.dueDate);
    final accentColor = _getDeadlineAccentColor(hours);
    final bgColor = _getDeadlineBgColor(hours);
    final badgeText = task.dueDate == null ? 'Tidak Ada' : _getDeadlineBadgeFromHours(hours);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
        boxShadow: badgeText == "Terlambat" || badgeText == "Hari Ini" 
            ? AppTheme.softShadow 
            : null, // Beri shadow jika urgent
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              badgeText == "Terlambat" ? Icons.warning_rounded : Icons.assignment_rounded, 
              color: accentColor, 
              size: 28
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        badgeText,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: accentColor.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      task.dueDate == null
                        ? "Tanpa Deadline"
                        : "${formatter.format(task.dueDate!)} • ${timeFormatter.format(task.dueDate!)}",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: accentColor.withValues(alpha: 0.8),
                      ),
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
  String _getDeadlineBadge(DateTime? dueDate) {
    if (dueDate == null) return "Tidak Ada";
    final hours = _hoursUntilDeadline(dueDate);
    return _getDeadlineBadgeFromHours(hours);
  }

  Widget _buildSmallTaskCard(
      TaskModel task, DateFormat formatter, Color bgColor, Color accentColor) {
    final hours = _hoursUntilDeadline(task.dueDate);
    final Color finalAccent = task.dueDate == null ? AppTheme.slateGray : _getDeadlineAccentColor(hours);
    final Color finalBg = task.dueDate == null ? AppTheme.cardColor : _getDeadlineBgColor(hours);
    final badgeText = task.dueDate == null ? 'Tidak Ada' : _getDeadlineBadgeFromHours(hours);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: finalAccent.withValues(alpha: 0.15)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: finalBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.assignment_outlined, size: 16, color: finalAccent),
              ),
              if (badgeText != "Tidak Ada")
                Text(
                  badgeText,
                  style: GoogleFonts.inter(
                      fontSize: 10, fontWeight: FontWeight.bold, color: finalAccent),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            task.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              height: 1.2,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : AppTheme.slateDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(double progress, int completed, int total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.slateGray.withValues(alpha: 0.1)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Text(
                    '${(progress * 100).toInt()}%',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tingkat Penyelesaian',
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : AppTheme.slateDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  total == 0
                      ? 'Belum ada tugas ditambahkan'
                      : '$completed dari $total tugas selesai',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.slateGray,
                  ),
                ),
                if (total > 0) ...[
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
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

  Widget _buildMotivationCard() {
    final quotes = [
      "Sedikit demi sedikit, lama-lama menjadi pintar.",
      "Belajar hari ini adalah investasi untuk masa depan.",
      "Jangan menunggu semangat datang, mulailah maka semangat akan mengikuti.",
      "Tugas yang selesai lebih baik daripada tugas yang sempurna tetapi tidak selesai.",
      "Konsisten adalah kunci keberhasilan."
    ];

    final quote = quotes[DateTime.now().day % quotes.length];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.15)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Text("💡", style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Motivasi Hari Ini",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  quote,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.5,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.9)
                        : AppTheme.slateDark,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
