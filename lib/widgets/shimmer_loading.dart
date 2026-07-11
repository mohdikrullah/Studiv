import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';

/// Shimmer loading placeholder widget reusable across the app.
class ShimmerLoading extends StatelessWidget {
  final Widget child;
  const ShimmerLoading({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
      highlightColor: isDark ? const Color(0xFF475569) : const Color(0xFFF8FAFC),
      child: child,
    );
  }
}

/// Horizontal schedule card skeleton (for Dashboard)
class ScheduleCardSkeleton extends StatelessWidget {
  const ScheduleCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Row(
        children: List.generate(3, (_) => _scheduleBox()),
      ),
    );
  }

  Widget _scheduleBox() {
    return Container(
      width: 180,
      height: 140,
      margin: const EdgeInsets.only(left: 16, right: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
    );
  }
}

/// List task card skeleton (for Tasks/Schedule screens)
class TaskCardSkeleton extends StatelessWidget {
  final int count;
  const TaskCardSkeleton({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(count, (_) => _taskBox()),
        ),
      ),
    );
  }

  Widget _taskBox() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 76,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

/// Dashboard section skeleton (banner + stats)
class DashboardSectionSkeleton extends StatelessWidget {
  const DashboardSectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 180, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28))),
            const SizedBox(height: 24),
            Container(height: 20, width: 140, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
            const SizedBox(height: 12),
            Row(
              children: List.generate(3, (i) => Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: i == 0 ? 0 : 14),
                  height: 140,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
