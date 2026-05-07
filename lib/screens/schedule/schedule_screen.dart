import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/schedule_provider.dart';
import '../../models/schedule_model.dart';
import '../../theme/app_theme.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _days.length, vsync: this);
    // Load schedules on init
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
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.slateGray,
          indicatorColor: AppTheme.primaryColor,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold),
          tabs: _days.map((day) => Tab(text: day)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _days.map((day) => _buildScheduleList(day)).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddScheduleDialog(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildScheduleList(String day) {
    return Consumer<ScheduleProvider>(
      builder: (context, provider, child) {
        final daySchedules = provider.schedules.where((s) => s.day == day).toList();

        if (daySchedules.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today_outlined, size: 64, color: AppTheme.slateGray.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text(
                  'Tidak ada jadwal untuk hari $day',
                  style: GoogleFonts.inter(color: AppTheme.slateGray),
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
      },
    );
  }

  Widget _buildScheduleCard(ScheduleModel schedule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 6,
                color: AppTheme.primaryColor,
              ),
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
                                color: AppTheme.slateDark,
                              ),
                            ),
                          ),
                          _buildActionMenu(schedule),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 16, color: AppTheme.slateGray),
                          const SizedBox(width: 4),
                          Text(
                            schedule.time,
                            style: GoogleFonts.inter(color: AppTheme.slateGray, fontSize: 13),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.location_on_outlined, size: 16, color: AppTheme.slateGray),
                          const SizedBox(width: 4),
                          Text(
                            schedule.room,
                            style: GoogleFonts.inter(color: AppTheme.slateGray, fontSize: 13),
                          ),
                        ],
                      ),
                      if (schedule.lecturer != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.person_outline_rounded, size: 16, color: AppTheme.slateGray),
                            const SizedBox(width: 4),
                            Text(
                              schedule.lecturer!,
                              style: GoogleFonts.inter(
                                color: AppTheme.slateGray,
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
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
              Text(
                isEdit ? 'Edit Jadwal' : 'Tambah Jadwal Baru',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.slateDark,
                ),
              ),
              const SizedBox(height: 24),
              _buildFieldLabel('Mata Kuliah'),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Contoh: Algoritma'),
              ),
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
                        TextField(
                          controller: roomController,
                          decoration: const InputDecoration(hintText: 'R. 301'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildFieldLabel('Dosen (Opsional)'),
              TextField(
                controller: lecturerController,
                decoration: const InputDecoration(hintText: 'Nama Dosen'),
              ),
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
                    items: _days.map((day) {
                      return DropdownMenuItem(value: day, child: Text(day));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedDay = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      final newSchedule = ScheduleModel(
                        id: isEdit ? schedule.id : DateTime.now().toString(),
                        subject: nameController.text,
                        time: timeController.text,
                        room: roomController.text,
                        day: selectedDay,
                        lecturer: lecturerController.text,
                      );
                      
                      if (isEdit) {
                        context.read<ScheduleProvider>().updateSchedule(newSchedule);
                      } else {
                        context.read<ScheduleProvider>().addSchedule(newSchedule);
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Jadwal'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: AppTheme.slateGray,
        ),
      ),
    );
  }
}
