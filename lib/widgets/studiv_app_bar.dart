import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/navigation_provider.dart';

// ─────────────────────────────────────────────────────────────
//  StudivAppBar
//  Gunakan sebagai `appBar:` pada Scaffold.
//
//  Parameter:
//  • hasNotif   – tampilkan badge merah di ikon lonceng
//  • onNotifTap – callback tombol lonceng
// ─────────────────────────────────────────────────────────────
class StudivAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool hasNotif;
  final VoidCallback? onNotifTap;

  const StudivAppBar({
    super.key,
    this.hasNotif = true,
    this.onNotifTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: Colors.black12,
      surfaceTintColor: Colors.transparent,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: AppTheme.slateLight),
      ),
      // ─── Title STUDIV (kiri) ───
      title: Text(
        'STUDIV',
        style: GoogleFonts.outfit(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.w800,
          fontSize: 22,
          letterSpacing: 2,
        ),
      ),
      titleSpacing: 20,
      // ─── Actions (kanan) ───
      actions: [
        _NotifButton(hasNotif: hasNotif, onTap: onNotifTap),
        const SizedBox(width: 8),
        _ProfileAvatar(),
        const SizedBox(width: 16),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  _NotifButton — IconButton lonceng + badge merah
// ─────────────────────────────────────────────────────────────
class _NotifButton extends StatelessWidget {
  final bool hasNotif;
  final VoidCallback? onTap;

  const _NotifButton({required this.hasNotif, this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onTap,
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: AppTheme.slateDark,
                    size: 24,
                  ),
                ),
              ),
            ),
            // Badge merah
            if (hasNotif)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  _ProfileAvatar — CircleAvatar yang navigasi ke tab Profil
// ─────────────────────────────────────────────────────────────
class _ProfileAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => navProvider.setIndex(3),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.35),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            backgroundImage: _buildAvatarImage(user?.profilePicture),
            child: user?.profilePicture == null
                ? Icon(Icons.person_rounded,
                    size: 18, color: AppTheme.primaryColor)
                : null,
          ),
        ),
      ),
    );
  }

  ImageProvider? _buildAvatarImage(String? path) {
    if (path == null || path.isEmpty) return null;
    if (kIsWeb) return NetworkImage(path);
    final f = File(path);
    if (f.existsSync()) return FileImage(f);
    return null;
  }
}
