import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/grade_provider.dart';
import '../../services/local_db_service.dart';
import '../../utils/navigation_utils.dart';

// Kondisional import untuk mobile saja
import 'share_grades_web_stub.dart'
    if (dart.library.io) 'share_grades_mobile_helper.dart';

class ShareGradesScreen extends StatefulWidget {
  const ShareGradesScreen({super.key});

  @override
  State<ShareGradesScreen> createState() => _ShareGradesScreenState();
}

class _ShareGradesScreenState extends State<ShareGradesScreen> {
  bool _shareGrades = false;
  bool _isProcessing = false;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _shareGrades = LocalDbService.getData('shareGrades') ?? false;
  }

  void _toggleShare(bool val) {
    setState(() => _shareGrades = val);
    LocalDbService.saveData('shareGrades', val);
  }

  String _getPredikat(double ipk) {
    if (ipk >= 3.51) return 'Dengan Pujian';
    if (ipk >= 3.01) return 'Sangat Memuaskan';
    if (ipk >= 2.76) return 'Memuaskan';
    if (ipk >= 2.0) return 'Cukup';
    return 'Kurang Memuaskan';
  }

  Color _getPredikatColor(double ipk) {
    if (ipk >= 3.51) return const Color(0xFFFFD700);
    if (ipk >= 3.01) return const Color(0xFF34D399);
    if (ipk >= 2.76) return const Color(0xFF60A5FA);
    return Colors.white70;
  }

  Future<void> _onSharePressed() async {
    setState(() => _isProcessing = true);
    try {
      final Uint8List? imageBytes = await _screenshotController.capture(pixelRatio: 3.0);
      if (imageBytes == null) return;

      if (kIsWeb) {
        // Di Web: download saja karena Share API web tidak support file gambar di semua browser
                downloadOnWeb(imageBytes, 'studiv_achievement.png');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(children: [
                Icon(Icons.info_rounded, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Expanded(child: Text('Di browser: file akan diunduh. Bagikan via Android/iOS untuk share langsung!')),
              ]),
              backgroundColor: AppTheme.primaryColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } else {
        // Di Mobile: share langsung ke WhatsApp/Instagram/dll
        await shareImageOnMobile(imageBytes, '🎓 Lihat pencapaian akademik saya di STUDIV!');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membagikan: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _onDownloadPressed() async {
    setState(() => _isProcessing = true);
    try {
      final Uint8List? imageBytes = await _screenshotController.capture(pixelRatio: 3.0);
      if (imageBytes == null) return;

      if (kIsWeb) {
                downloadOnWeb(imageBytes, 'studiv_achievement.png');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(children: [
                Icon(Icons.download_done_rounded, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text('Kartu berhasil diunduh ke folder Downloads!'),
              ]),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } else {
        await saveImageOnMobile(imageBytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text('Kartu berhasil disimpan!'),
              ]),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final gradeProvider = context.watch<GradeProvider>();
    final user = authProvider.user;
    final ipk = gradeProvider.calculateIPK();
    final totalSks = gradeProvider.calculateTotalSKS();
    final semester = user?.semester ?? 1;

    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && Navigator.canPop(context)) {
          Navigator.pop(context);
        } else if (!didPop) {
          NavigationUtils.safeBack(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.surfaceColor,
        appBar: AppBar(
          backgroundColor: AppTheme.cardColor,
          elevation: 0,
          title: Text(
            'BAGIKAN NILAI',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: AppTheme.primaryColor,
            ),
          ),
          leading: buildSafeBackButton(context, color: AppTheme.slateDark),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 14),
                child: Text(
                  'Preview Kartu Digital',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.slateDark,
                  ),
                ),
              ),

              // === KARTU DIGITAL ===
              Screenshot(
                controller: _screenshotController,
                child: _buildAchievementCard(user, ipk, totalSks, semester, gradeProvider),
              ),

              const SizedBox(height: 24),

              // === TOMBOL AKSI ===
              _isProcessing
                  ? const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _onDownloadPressed,
                            icon: const Icon(Icons.download_rounded),
                            label: Text('Unduh', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              side: BorderSide(color: AppTheme.primaryColor),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _onSharePressed,
                            icon: const Icon(Icons.share_rounded),
                            label: Text('Bagikan', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                      ],
                    ),

              const SizedBox(height: 32),

              // === PENGATURAN PRIVASI ===
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.slateGray.withValues(alpha: 0.1)),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.privacy_tip_rounded, color: AppTheme.primaryColor, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Pengaturan Privasi', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.slateDark)),
                                Text('Atur siapa saja yang dapat melihat nilai Anda', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.slateGray)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        title: Text('Izinkan Teman Melihat Nilai', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppTheme.slateDark)),
                        subtitle: Text(
                          _shareGrades ? 'Nilai Anda dapat dilihat orang lain' : 'Nilai Anda bersifat pribadi',
                          style: GoogleFonts.inter(fontSize: 12, color: AppTheme.slateGray),
                        ),
                        value: _shareGrades,
                        activeThumbColor: AppTheme.primaryColor,
                        activeTrackColor: AppTheme.primaryColor.withValues(alpha: 0.3),
                        onChanged: _toggleShare,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementCard(dynamic user, double ipk, int totalSks, int semester, GradeProvider gradeProvider) {
    final predikat = _getPredikat(ipk);
    final predikatColor = _getPredikatColor(ipk);

    final semesterList = List.generate(semester.clamp(0, 4), (i) {
      final sem = i + 1;
      return {'sem': sem, 'ips': gradeProvider.calculateIPS(sem)};
    }).reversed.take(3).toList();

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4C3A8D), Color(0xFF7B5EA7), Color(0xFF9B72CF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Stack(
        children: [
          Positioned(top: -40, right: -40, child: Container(width: 160, height: 160, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.05)))),
          Positioned(bottom: -30, left: -30, child: Container(width: 130, height: 130, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.05)))),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('STUDIV', style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2)),
                        Text('Academic Achievement Card', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                      child: const Icon(Icons.school_rounded, color: Colors.white, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2)),
                      child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user?.fullName ?? user?.username ?? 'Nama Mahasiswa', style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                          Text('@${user?.username ?? 'username'} · Semester $semester', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.75), fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Center(
                  child: Column(
                    children: [
                      Text(ipk.toStringAsFixed(2), style: GoogleFonts.outfit(color: Colors.white, fontSize: 72, fontWeight: FontWeight.w900, height: 1)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: predikatColor.withValues(alpha: 0.5))),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.star_rounded, color: predikatColor, size: 16),
                          const SizedBox(width: 6),
                          Text(predikat, style: GoogleFonts.inter(color: predikatColor, fontWeight: FontWeight.bold, fontSize: 13)),
                        ]),
                      ),
                      const SizedBox(height: 6),
                      Text('IPK Kumulatif · $totalSks SKS Ditempuh', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                    ],
                  ),
                ),
                if (semesterList.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  Divider(color: Colors.white.withValues(alpha: 0.2), thickness: 1),
                  const SizedBox(height: 16),
                  Text('IPS per Semester', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.6), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  Row(
                    children: semesterList.map((s) {
                      final ips = s['ips'] as double;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                            child: Column(children: [
                              Text(ips.toStringAsFixed(2), style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                              Text('Sem ${s['sem']}', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.65), fontSize: 11)),
                            ]),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 24),
                Center(child: Text('📱 Dibuat dengan STUDIV App', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.45), fontSize: 11))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
