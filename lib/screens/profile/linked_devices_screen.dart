import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../utils/navigation_utils.dart';

class LinkedDevicesScreen extends StatelessWidget {
  const LinkedDevicesScreen({super.key});

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
        title: Text('PERANGKAT TERTAUT', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        leading: buildSafeBackButton(
          context,
          color: AppTheme.slateDark,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Kelola perangkat yang saat ini masuk ke akun Studiv Anda.',
            style: GoogleFonts.inter(color: AppTheme.slateGray, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Text('SAAT INI AKTIF', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.slateGray)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.softShadow,
            ),
            child: ListTile(
              leading: const Icon(Icons.phone_android_rounded, color: AppTheme.primaryColor, size: 32),
              title: Text('Perangkat Ini', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              subtitle: Text('Aktif sekarang • Jakarta, Indonesia', style: GoogleFonts.inter(color: Colors.green, fontSize: 12)),
            ),
          ),
          const SizedBox(height: 32),
          Text('PERANGKAT LAIN', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.slateGray)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.softShadow,
            ),
            child: ListTile(
              leading: Icon(Icons.computer_rounded, color: AppTheme.slateGray, size: 32),
              title: Text('Windows PC', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              subtitle: Text('Terakhir aktif: Kemarin • Bandung, Indonesia', style: GoogleFonts.inter(color: AppTheme.slateGray, fontSize: 12)),
              trailing: IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.red),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perangkat berhasil dihapus dari sesi')));
                },
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}
