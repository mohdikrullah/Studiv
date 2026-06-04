import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/local_db_service.dart';

class ProfileVisibilityScreen extends StatefulWidget {
  const ProfileVisibilityScreen({super.key});

  @override
  State<ProfileVisibilityScreen> createState() => _ProfileVisibilityScreenState();
}

class _ProfileVisibilityScreenState extends State<ProfileVisibilityScreen> {
  String _profileVisibility = 'Publik';

  @override
  void initState() {
    super.initState();
    _profileVisibility = LocalDbService.getData('profileVisibility') ?? 'Publik';
  }

  void _updateVisibility(String val) {
    setState(() => _profileVisibility = val);
    LocalDbService.saveData('profileVisibility', val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('VISIBILITAS PROFIL', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.slateDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Siapa yang dapat melihat profil Anda?',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.slateDark),
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih siapa saja yang bisa melihat informasi kampus dan semester Anda.',
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
                  title: Text('Publik', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  subtitle: Text('Semua pengguna Studiv dapat melihat profil Anda', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.slateGray)),
                  value: 'Publik',
                  groupValue: _profileVisibility,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (val) => _updateVisibility(val!),
                ),
                const Divider(height: 1),
                RadioListTile<String>(
                  title: Text('Teman', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  subtitle: Text('Hanya pengguna yang Anda ikuti', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.slateGray)),
                  value: 'Teman',
                  groupValue: _profileVisibility,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (val) => _updateVisibility(val!),
                ),
                const Divider(height: 1),
                RadioListTile<String>(
                  title: Text('Privat', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  subtitle: Text('Hanya Anda yang dapat melihat profil Anda', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.slateGray)),
                  value: 'Privat',
                  groupValue: _profileVisibility,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (val) => _updateVisibility(val!),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
