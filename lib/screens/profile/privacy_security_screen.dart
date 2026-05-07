import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'PRIVASI & KEAMANAN',
          style: GoogleFonts.outfit(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.slateDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Keamanan Akun'),
            const SizedBox(height: 16),
            _buildMenuTile(
              'Ubah Password',
              'Terakhir diubah 3 bulan yang lalu',
              Icons.lock_reset_rounded,
              () {},
            ),
            _buildMenuTile(
              'Otentikasi Dua Faktor',
              'Amankan akun dengan verifikasi tambahan',
              Icons.verified_user_outlined,
              () {},
            ),
            _buildMenuTile(
              'Perangkat Tertaut',
              'Lihat di mana saja Anda login',
              Icons.devices_rounded,
              () {},
            ),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Privasi Data'),
            const SizedBox(height: 16),
            _buildMenuTile(
              'Visibilitas Profil',
              'Atur siapa saja yang bisa melihat profil Anda',
              Icons.visibility_outlined,
              () {},
            ),
            _buildMenuTile(
              'Bagikan Nilai',
              'Izinkan teman melihat pencapaian akademik',
              Icons.share_outlined,
              () {},
            ),
            _buildMenuTile(
              'Hapus Akun',
              'Hapus permanen data dan akun Studiv',
              Icons.delete_outline_rounded,
              () {},
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppTheme.slateGray,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildMenuTile(String title, String subtitle, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isDestructive ? Colors.red : AppTheme.primaryColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: isDestructive ? Colors.redAccent : AppTheme.primaryColor, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold, 
            fontSize: 14, 
            color: isDestructive ? Colors.redAccent : AppTheme.slateDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.slateGray),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.slateGray, size: 20),
      ),
    );
  }
}
