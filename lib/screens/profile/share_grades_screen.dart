import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/local_db_service.dart';
import '../../utils/navigation_utils.dart';

class ShareGradesScreen extends StatefulWidget {
  const ShareGradesScreen({super.key});

  @override
  State<ShareGradesScreen> createState() => _ShareGradesScreenState();
}

class _ShareGradesScreenState extends State<ShareGradesScreen> {
  bool _shareGrades = false;

  @override
  void initState() {
    super.initState();
    _shareGrades = LocalDbService.getData('shareGrades') ?? false;
  }

  void _toggleShare(bool val) {
    setState(() => _shareGrades = val);
    LocalDbService.saveData('shareGrades', val);
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
          title: Text('BAGIKAN NILAI', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          leading: buildSafeBackButton(
            context,
            color: AppTheme.slateDark,
          ),
        ),
        body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.analytics_outlined, color: AppTheme.primaryColor, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bagikan Pencapaian', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('Pamerkan IPK dan nilai Anda ke teman-teman di platform ini.', style: GoogleFonts.inter(color: AppTheme.slateGray, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Izinkan Teman Melihat Nilai', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  value: _shareGrades,
                  activeColor: AppTheme.primaryColor,
                  onChanged: _toggleShare,
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
