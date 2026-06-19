import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../utils/navigation_utils.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

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
        title: Text(
          'PUSAT BANTUAN',
          style: GoogleFonts.outfit(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
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
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.softShadow,
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari bantuan...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search_rounded, color: AppTheme.slateGray),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            _buildSectionTitle('FAQ Populer'),
            const SizedBox(height: 16),
            _buildFaqItem('Bagaimana cara menghitung IPK?', 'IPK dihitung berdasarkan total nilai dibagi total SKS...'),
            _buildFaqItem('Lupa password akun Studiv?', 'Anda dapat mengatur ulang password melalui halaman login...'),
            _buildFaqItem('Cara sinkronisasi jadwal?', 'Jadwal akan otomatis tersinkron saat Anda login...'),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Hubungi Kami'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildContactCard(
                    'Email Support',
                    'support@studiv.id',
                    Icons.email_outlined,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildContactCard(
                    'WhatsApp',
                    '+62 812-3456-789',
                    Icons.chat_outlined,
                    Colors.green,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Versi Aplikasi 1.0.0',
                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.slateGray),
              ),
            ),
          ],
        ),
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

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.slateDark),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.slateGray, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.slateDark),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 11, color: AppTheme.slateGray),
          ),
        ],
      ),
    );
  }
}
