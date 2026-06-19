import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/local_db_service.dart';
import '../../utils/navigation_utils.dart';
import 'sms_auth_screen.dart';

class TwoFactorAuthScreen extends StatefulWidget {
  const TwoFactorAuthScreen({super.key});

  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  bool _is2FAEnabled = false;
  bool _isSmsEnabled = false;
  String _smsPhoneNumber = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _is2FAEnabled = LocalDbService.getData('is2FAEnabled') ?? false;
      _isSmsEnabled = LocalDbService.getData('isSmsEnabled') ?? false;
      _smsPhoneNumber = LocalDbService.getData('smsPhoneNumber') ?? '';
    });
  }

  void _toggle2FA(bool val) {
    setState(() {
      _is2FAEnabled = val;
    });
    LocalDbService.saveData('is2FAEnabled', val);
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
          title: Text('OTENTIKASI DUA FAKTOR', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
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
                      child: const Icon(Icons.security_rounded, color: AppTheme.primaryColor, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Keamanan Ekstra', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('Lindungi akun Anda dengan lapisan keamanan tambahan.', style: GoogleFonts.inter(color: AppTheme.slateGray, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Autentikator Aplikasi', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  subtitle: Text('Gunakan aplikasi seperti Google Authenticator', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.slateGray)),
                  value: _is2FAEnabled,
                  activeColor: AppTheme.primaryColor,
                  onChanged: _toggle2FA,
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Pesan Teks (SMS)', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    _isSmsEnabled ? 'Aktif ke nomor $_smsPhoneNumber' : 'Kirim kode login ke nomor HP Anda', 
                    style: GoogleFonts.inter(fontSize: 12, color: _isSmsEnabled ? Colors.green : AppTheme.slateGray)
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.slateGray),
                  onTap: () async {
                    final result = await Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => const SmsAuthScreen())
                    );
                    if (result == true) {
                      _loadSettings();
                    }
                  },
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
