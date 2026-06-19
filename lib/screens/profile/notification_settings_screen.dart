import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../theme/app_theme.dart';
import '../../services/local_db_service.dart';
import '../../utils/navigation_utils.dart';
import 'package:path_provider/path_provider.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  String _selectedSound = 'default';
  String _customSoundPath = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _customSoundPath = LocalDbService.getData('alarmSoundPath') ?? '';
    if (_customSoundPath.isNotEmpty && _customSoundPath != 'default') {
      _selectedSound = 'custom';
    } else {
      _selectedSound = 'default';
    }
  }

  void _saveSound(String value) {
    setState(() => _selectedSound = value);
    if (value == 'default') {
      LocalDbService.saveData('alarmSoundPath', 'default');
    }
  }

  Future<void> _pickCustomAudio() async {
    setState(() => _isLoading = true);
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.audio,
      );

      if (result != null && result.files.single.path != null) {
        final originalFile = File(result.files.single.path!);
        
        // Copy to app directory to prevent access issues
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = result.files.single.name;
        final savedImage = await originalFile.copy('${appDir.path}/$fileName');

        setState(() {
          _selectedSound = 'custom';
          _customSoundPath = savedImage.path;
        });

        LocalDbService.saveData('alarmSoundPath', savedImage.path);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nada khusus berhasil disimpan!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih file: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          title: Text('PENGATURAN NOTIFIKASI', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          leading: buildSafeBackButton(
            context,
            color: AppTheme.slateDark,
          ),
        ),
        body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Nada Alarm Kuliah',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.slateDark),
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih nada dering yang akan digunakan untuk pengingat jadwal kuliah (H-60, H-45, H-30, H-15).',
            style: GoogleFonts.inter(color: AppTheme.slateGray, fontSize: 13),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              children: [
                RadioListTile<String>(
                  title: Text('Nada Bawaan Sistem', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  subtitle: Text('Default device sound', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.slateGray)),
                  value: 'default',
                  groupValue: _selectedSound,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (val) => _saveSound(val!),
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text('Pilih dari File Manager', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    _selectedSound == 'custom' ? 'File: ${_customSoundPath.split('/').last}' : 'Format yang didukung: MP3, WAV',
                    style: GoogleFonts.inter(fontSize: 12, color: _selectedSound == 'custom' ? Colors.green : AppTheme.slateGray),
                  ),
                  trailing: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.audio_file_rounded, color: AppTheme.primaryColor),
                  onTap: _pickCustomAudio,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: Colors.orange, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Catatan: Pemilihan nada dari file kustom mungkin tidak didukung di semua perangkat Android karena pembatasan keamanan OS (Scoped Storage). Jika alarm tidak berbunyi, gunakan nada bawaan.',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.orange.shade900),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}
