import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/local_db_service.dart';
import '../../utils/navigation_utils.dart';

class SmsAuthScreen extends StatefulWidget {
  const SmsAuthScreen({super.key});

  @override
  State<SmsAuthScreen> createState() => _SmsAuthScreenState();
}

class _SmsAuthScreenState extends State<SmsAuthScreen> {
  final _phoneController = TextEditingController();
  bool _isSmsEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isSmsEnabled = LocalDbService.getData('isSmsEnabled') ?? false;
    _phoneController.text = LocalDbService.getData('smsPhoneNumber') ?? '';
  }

  void _saveSmsSettings() async {
    if (_phoneController.text.trim().isEmpty && !_isSmsEnabled) {
      Navigator.pop(context, false);
      return;
    }
    
    if (_phoneController.text.trim().length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nomor handphone tidak valid'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    // Simulasi loading pengiriman/verifikasi
    await Future.delayed(const Duration(seconds: 1));

    LocalDbService.saveData('isSmsEnabled', true);
    LocalDbService.saveData('smsPhoneNumber', _phoneController.text.trim());

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Autentikasi SMS berhasil diaktifkan!'), backgroundColor: Colors.green));
      Navigator.pop(context, true); // Return true to indicate change
    }
  }
  
  void _disableSms() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    LocalDbService.saveData('isSmsEnabled', false);
    LocalDbService.saveData('smsPhoneNumber', '');
    if (mounted) {
      setState(() {
        _isLoading = false;
        _isSmsEnabled = false;
        _phoneController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Autentikasi SMS dinonaktifkan')));
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvoked: (didPop) {
        if (!didPop && Navigator.canPop(context)) {
          Navigator.pop(context, false);
        } else if (!didPop) {
          NavigationUtils.safeBack(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text('AUTENTIKASI SMS', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          leading: buildSafeBackButton(
            context,
            color: AppTheme.slateDark,
          ),
        ),
        body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Icon(Icons.message_rounded, size: 64, color: AppTheme.primaryColor.withOpacity(0.8)),
          const SizedBox(height: 24),
          Text(
            _isSmsEnabled ? 'Autentikasi SMS Aktif' : 'Atur Autentikasi SMS',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.slateDark),
          ),
          const SizedBox(height: 12),
          Text(
            'Kami akan mengirimkan kode login khusus ke nomor ini setiap kali Anda masuk ke akun Studiv.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: AppTheme.slateGray, fontSize: 14),
          ),
          const SizedBox(height: 40),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Nomor Handphone',
              hintText: 'Contoh: 081234567890',
              prefixIcon: Icon(Icons.phone_rounded, color: AppTheme.slateGray),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveSmsSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(_isSmsEnabled ? 'Perbarui Nomor' : 'Aktifkan SMS 2FA', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          if (_isSmsEnabled) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isLoading ? null : _disableSms,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Nonaktifkan SMS 2FA', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
}
