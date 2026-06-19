import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/local_db_service.dart';
import '../../utils/navigation_utils.dart';
import '../auth/login_screen.dart';

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

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
        title: Text('HAPUS AKUN', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        leading: buildSafeBackButton(
          context,
          color: AppTheme.slateDark,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                      const SizedBox(width: 12),
                      Text('Tindakan Berbahaya', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Anda akan menghapus akun Studiv Anda. Ini tidak dapat dibatalkan.',
                    style: GoogleFonts.inter(color: Colors.red.shade900, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Semua data Anda termasuk jadwal, tugas, dan histori nilai akan dihapus secara permanen dari perangkat.',
                    style: GoogleFonts.inter(color: Colors.red.shade900, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  // Munculkan dialog konfirmasi terakhir
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: Colors.white,
                      title: Text('Konfirmasi Hapus', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                      content: Text('Apakah Anda sangat yakin ingin menghapus akun?', style: GoogleFonts.inter()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Batal', style: TextStyle(color: AppTheme.slateGray)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () async {
                            Navigator.pop(ctx);
                            final authProvider = Provider.of<AuthProvider>(context, listen: false);
                            final username = authProvider.user?.username;
                            
                            if (username != null) {
                              await LocalDbService.usersBox.delete(username);
                              await LocalDbService.closeUser();
                              
                              if (context.mounted) {
                                await authProvider.logout();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                                  (route) => false,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Akun berhasil dihapus.'), backgroundColor: Colors.redAccent),
                                );
                              }
                            }
                          },
                          child: const Text('Ya, Hapus'),
                        ),
                      ],
                    ),
                  );
                },
                child: Text('Hapus Akun Saya', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
