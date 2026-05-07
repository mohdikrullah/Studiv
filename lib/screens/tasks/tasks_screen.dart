import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/task_provider.dart';
import '../../models/task_model.dart';
import '../../theme/app_theme.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _statuses = ['To-Do', 'In Progress', 'Done'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().fetchTasks();
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
          'TUGAS SAYA',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
            letterSpacing: 1.2,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.slateGray,
          indicatorColor: AppTheme.primaryColor,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Belum Mulai'),
            Tab(text: 'Dikerjakan'),
            Tab(text: 'Selesai'),
          ],
        ),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: _statuses.map((status) => _buildTaskList(status, provider)).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add_task_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildTaskList(String status, TaskProvider provider) {
    final filteredTasks = provider.tasks.where((t) => t.status == status).toList();

    if (filteredTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == 'Done' ? Icons.task_alt_rounded : Icons.assignment_outlined,
              size: 64,
              color: AppTheme.slateGray.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada tugas di kategori ini',
              style: GoogleFonts.inter(color: AppTheme.slateGray),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        return _buildTaskCard(task, provider);
      },
    );
  }

  Widget _buildTaskCard(TaskModel task, TaskProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: GestureDetector(
          onTap: () {
            // Cycle status
            String nextStatus;
            if (task.status == 'To-Do') nextStatus = 'In Progress';
            else if (task.status == 'In Progress') nextStatus = 'Done';
            else nextStatus = 'To-Do';
            
            provider.updateTask(TaskModel(
              id: task.id,
              title: task.title,
              description: task.description,
              status: nextStatus,
              dueDate: task.dueDate,
            ));
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: task.status == 'Done' 
                    ? Colors.green 
                    : (task.status == 'In Progress' ? Colors.orangeAccent : AppTheme.primaryColor),
                width: 2,
              ),
              color: task.status == 'Done' 
                  ? Colors.green 
                  : (task.status == 'In Progress' ? Colors.orangeAccent.withValues(alpha: 0.1) : Colors.transparent),
            ),
            child: task.status == 'Done' 
              ? const Icon(Icons.check, size: 18, color: Colors.white)
              : (task.status == 'In Progress' 
                  ? const Icon(Icons.access_time_rounded, size: 16, color: Colors.orangeAccent)
                  : null),
          ),
        ),
        title: Text(
          task.title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: task.status == 'Done' ? AppTheme.slateGray : AppTheme.slateDark,
            decoration: task.status == 'Done' ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty)
              Text(
                task.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.slateGray),
              ),
            if (task.dueDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 12, color: AppTheme.primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd MMM yyyy').format(task.dueDate!),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (task.status == 'Done' 
                    ? Colors.green 
                    : (task.status == 'In Progress' ? Colors.orangeAccent : AppTheme.primaryColor)).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                task.status,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: task.status == 'Done' 
                      ? Colors.green 
                      : (task.status == 'In Progress' ? Colors.orangeAccent : AppTheme.primaryColor),
                ),
              ),
            ),
            _buildTaskActionMenu(task, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskActionMenu(TaskModel task, TaskProvider provider) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz_rounded, color: AppTheme.slateGray),
      onSelected: (value) {
        if (value == 'delete') {
          provider.deleteTask(task.id);
        } else if (value == 'edit') {
          _showAddTaskDialog(context, task: task);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Text('Edit')),
        const PopupMenuItem(value: 'delete', child: Text('Hapus')),
      ],
    );
  }

  void _showAddTaskDialog(BuildContext context, {TaskModel? task}) {
    final isEdit = task != null;
    final titleController = TextEditingController(text: task?.title ?? '');
    final descController = TextEditingController(text: task?.description ?? '');
    String currentStatus = task?.status ?? 'To-Do';
    DateTime? selectedDate = task?.dueDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 24,
          left: 24,
          right: 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) => SingleChildScrollView(
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
                const SizedBox(height: 16),
                Text(
                  isEdit ? 'Edit Tugas' : 'Tambah Tugas Baru',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.slateDark,
                  ),
                ),
                const SizedBox(height: 24),
                _buildFieldLabel('Judul Tugas'),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(hintText: 'Contoh: Kerjakan Bab 1'),
                ),
                const SizedBox(height: 16),
                _buildFieldLabel('Deskripsi (Opsional)'),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(hintText: 'Tambahkan detail tugas...'),
                ),
                const SizedBox(height: 16),
                _buildFieldLabel('Deadline'),
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: AppTheme.primaryColor,
                              onPrimary: Colors.white,
                              onSurface: AppTheme.slateDark,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setModalState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.slateLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_month_rounded, color: AppTheme.primaryColor),
                        const SizedBox(width: 12),
                        Text(
                          selectedDate == null 
                            ? 'Pilih Tanggal Deadline' 
                            : DateFormat('EEEE, dd MMM yyyy').format(selectedDate!),
                          style: GoogleFonts.inter(
                            color: selectedDate == null ? AppTheme.slateGray : AppTheme.slateDark,
                            fontWeight: selectedDate == null ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (selectedDate != null)
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () {
                              setModalState(() {
                                selectedDate = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildFieldLabel('Status'),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _statuses.map((status) {
                    final isSelected = currentStatus == status;
                    Color statusColor;
                    switch (status) {
                      case 'To-Do': statusColor = AppTheme.primaryColor; break;
                      case 'In Progress': statusColor = Colors.orangeAccent; break;
                      case 'Done': statusColor = Colors.green; break;
                      default: statusColor = AppTheme.primaryColor;
                    }

                    return GestureDetector(
                      onTap: () {
                        setModalState(() {
                          currentStatus = status;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected 
                            ? statusColor.withValues(alpha: 0.1) 
                            : AppTheme.slateLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? statusColor : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected) ...[
                              Icon(Icons.check_circle_rounded, size: 18, color: statusColor),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              status,
                              style: GoogleFonts.inter(
                                color: isSelected ? statusColor : AppTheme.slateGray,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty) {
                        final newTask = TaskModel(
                          id: isEdit ? task.id : DateTime.now().toString(),
                          title: titleController.text,
                          description: descController.text,
                          status: currentStatus,
                          dueDate: selectedDate,
                        );
                        
                        if (isEdit) {
                          context.read<TaskProvider>().updateTask(newTask);
                        } else {
                          context.read<TaskProvider>().addTask(newTask);
                        }
                        Navigator.pop(context);
                      }
                    },
                    child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Tugas'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
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
