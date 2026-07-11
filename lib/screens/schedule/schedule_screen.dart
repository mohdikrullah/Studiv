import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/schedule_provider.dart';
import '../../models/schedule_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shimmer_loading.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _days = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
  ];

  @override
  void initState() {
    super.initState();
    final todayIndex = DateTime.now().weekday - 1;
    _tabController = TabController(
      length: _days.length,
      vsync: this,
      initialIndex: todayIndex.clamp(0, 6),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleProvider>().loadSchedules();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: Text(
          'JADWAL KULIAH',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
            letterSpacing: 1.2,
          ),
        ),
        elevation: 0,
        backgroundColor: AppTheme.cardColor,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: AppTheme.cardColor,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isMobile = constraints.maxWidth < 600;
                return TabBar(
                  controller: _tabController,
                  isScrollable: isMobile,
                  tabAlignment: isMobile ? TabAlignment.start : TabAlignment.fill,
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: AppTheme.slateGray,
                  indicatorColor: AppTheme.primaryColor,
                  indicatorWeight: 3,
                  labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                  unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 13),
                  tabs: _days.map((day) => Tab(height: 36, text: day)).toList(),
                );
              },
            ),
          ),
        ),
      ),
      body: Consumer<ScheduleProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Padding(
              padding: EdgeInsets.only(top: 16),
              child: TaskCardSkeleton(count: 5),
            );
          }
          return TabBarView(
            controller: _tabController,
            children: _days.map((day) => _buildScheduleList(day, provider)).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddScheduleDialog(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
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
              status = 'Berlangsung';
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

  Widget _buildScheduleList(String day, ScheduleProvider provider) {
    final daySchedules = provider.schedules
        .where((s) => s.day?.trim().toLowerCase() == day.toLowerCase())
        .toList();

    if (daySchedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                size: 56,
                color: AppTheme.primaryColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Tidak ada jadwal',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.slateDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tekan tombol + untuk menambah jadwal hari $day',
              style: GoogleFonts.inter(color: AppTheme.slateGray, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: daySchedules.length,
      itemBuilder: (context, index) {
        final schedule = daySchedules[index];
        return _buildScheduleCard(schedule);
      },
    );
  }

  Widget _buildScheduleCard(ScheduleModel schedule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.slateGray.withValues(alpha: 0.1)),
        boxShadow: AppTheme.softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 6, color: AppTheme.primaryColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              schedule.subject,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : AppTheme.slateDark,
                              ),
                            ),
                          ),
                          _buildActionMenu(schedule),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.schedule_rounded, size: 14, color: AppTheme.primaryColor),
                                const SizedBox(width: 4),
                                Text(
                                  schedule.time.isNotEmpty ? schedule.time : '--:--',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryColor),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          _buildScheduleStatusBadge(schedule.time),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded, size: 14, color: AppTheme.slateGray),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(schedule.room.isNotEmpty ? schedule.room : 'Ruang —', style: GoogleFonts.inter(color: AppTheme.slateGray, fontSize: 13)),
                          ),
                        ],
                      ),
                      if (schedule.lecturer != null && schedule.lecturer!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.person_rounded, size: 14, color: AppTheme.slateGray),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                schedule.lecturer!,
                                style: GoogleFonts.inter(
                                  color: AppTheme.slateGray, fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionMenu(ScheduleModel schedule) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, color: AppTheme.slateGray, size: 20),
      onSelected: (value) {
        if (value == 'edit') {
          _showAddScheduleDialog(context, schedule: schedule);
        } else if (value == 'delete') {
          context.read<ScheduleProvider>().deleteSchedule(schedule.id);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Text('Edit')),
        const PopupMenuItem(value: 'delete', child: Text('Hapus')),
      ],
    );
  }

  void _showAddScheduleDialog(BuildContext context, {ScheduleModel? schedule}) {
    final isEdit = schedule != null;
    final nameController = TextEditingController(text: schedule?.subject ?? '');
    final timeController = TextEditingController(text: schedule?.time ?? '');
    final roomController = TextEditingController(text: schedule?.room ?? '');
    final lecturerController = TextEditingController(text: schedule?.lecturer ?? '');

    String selectedDay = schedule?.day ?? _days[_tabController.index];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.slateLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isEdit ? 'Edit Jadwal' : 'Tambah Jadwal Baru',
                  style: GoogleFonts.outfit(
                    fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.slateDark,
                  ),
                ),
                const SizedBox(height: 24),
                _buildFieldLabel('Mata Kuliah'),
                TextField(controller: nameController, decoration: const InputDecoration(hintText: 'Contoh: Algoritma')),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Waktu'),
                          TextField(
                            controller: timeController,
                            decoration: const InputDecoration(hintText: '08:00 - 10:00'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Ruangan'),
                          TextField(controller: roomController, decoration: const InputDecoration(hintText: 'R. 301')),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFieldLabel('Dosen (Opsional)'),
                TextField(controller: lecturerController, decoration: const InputDecoration(hintText: 'Nama Dosen')),
                const SizedBox(height: 16),
                _buildFieldLabel('Hari'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.slateLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedDay,
                      isExpanded: true,
                      dropdownColor: AppTheme.cardColor,
                      items: _days.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
                      onChanged: (val) {
                        if (val != null) setSheetState(() => selectedDay = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _onSaveSchedule(
                      ctx,
                      isEdit: isEdit,
                      existingSchedule: schedule,
                      nameController: nameController,
                      timeController: timeController,
                      roomController: roomController,
                      lecturerController: lecturerController,
                      selectedDay: selectedDay,
                    ),
                    child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Jadwal'),
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

  Future<void> _onSaveSchedule(
    BuildContext ctx, {
    required bool isEdit,
    required ScheduleModel? existingSchedule,
    required TextEditingController nameController,
    required TextEditingController timeController,
    required TextEditingController roomController,
    required TextEditingController lecturerController,
    required String selectedDay,
  }) async {
    if (nameController.text.isEmpty) return;

    final provider = ctx.read<ScheduleProvider>();

    // --- Conflict Detection ---
    final conflict = provider.checkConflict(
      selectedDay,
      timeController.text,
      excludeId: existingSchedule?.id,
    );

    if (conflict != null && ctx.mounted) {
      final proceed = await showDialog<bool>(
        context: ctx,
        builder: (dialogCtx) => AlertDialog(
          backgroundColor: AppTheme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              const SizedBox(width: 8),
              Text('Jadwal Bentrok!', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.slateDark)),
            ],
          ),
          content: Text(
            'Jadwal ini tumpang tindih dengan "${conflict.subject}" pada hari $selectedDay (${conflict.time}).\n\nTetap simpan?',
            style: GoogleFonts.inter(color: AppTheme.slateGray),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: Text('Batal', style: GoogleFonts.inter(color: AppTheme.slateGray)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogCtx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text('Tetap Simpan', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    final newSchedule = ScheduleModel(
      id: isEdit ? existingSchedule!.id : DateTime.now().toString(),
      subject: nameController.text,
      time: timeController.text,
      room: roomController.text,
      day: selectedDay,
      lecturer: lecturerController.text,
    );

    if (isEdit) {
      provider.updateSchedule(newSchedule);
    } else {
      provider.addSchedule(newSchedule);
    }

    if (ctx.mounted) Navigator.pop(ctx);
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        label,
        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.slateGray),
      ),
    );
  }
}
