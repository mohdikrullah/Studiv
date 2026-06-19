import 'package:flutter/material.dart';

/// Navigation Utility untuk menangani back navigation dengan safe
/// Mencegah black screen saat navigation stack kosong
class NavigationUtils {
  /// Safe back navigation - cek canPop sebelum pop
  /// Jika tidak bisa pop, redirect ke home/dashboard
  static void safeBack(BuildContext context, {String? routeName}) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      // Jika stack kosong, arahkan ke dashboard
      Navigator.pushNamedAndRemoveUntil(
        context,
        routeName ?? '/',
        (route) => false,
      );
    }
  }

  /// Safe back navigation dengan callback optional
  static Future<void> safeBackWithCallback(
    BuildContext context, {
    String? routeName,
    VoidCallback? onNavigateHome,
  }) async {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      onNavigateHome?.call();
      Navigator.pushNamedAndRemoveUntil(
        context,
        routeName ?? '/',
        (route) => false,
      );
    }
  }

  /// Check apakah bisa pop dari current route
  static bool canPopScreen(BuildContext context) {
    return Navigator.canPop(context);
  }

  /// Navigate to screen dengan protection
  static Future<T?> navigateTo<T>(
    BuildContext context,
    Widget screen,
  ) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  /// Navigate to screen dengan custom route
  static Future<T?> navigateToWithRoute<T>(
    BuildContext context,
    Route<T> route,
  ) {
    return Navigator.push(context, route);
  }

  /// Replace current screen
  static Future<T?> replaceTo<T>(
    BuildContext context,
    Widget screen,
  ) {
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  /// Pop dengan value (untuk dialog/modal)
  static void popWithValue<T>(BuildContext context, T value) {
    Navigator.pop(context, value);
  }

  /// Pop sampai route tertentu
  static void popUntil(BuildContext context, RoutePredicate predicate) {
    Navigator.popUntil(context, predicate);
  }

  /// Pop dan replace dengan screen baru
  static void popAndPushNamed(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.popAndPushNamed(context, routeName, arguments: arguments);
  }
}

/// WillPopScope replacement untuk menangani back button di Android dan iOS
/// Gunakan widget ini sebagai wrapper untuk Scaffold yang perlu back handling
class SafeBackHandler extends StatefulWidget {
  final Widget child;
  final VoidCallback? onWillPop;
  final bool canPop;

  const SafeBackHandler({
    Key? key,
    required this.child,
    this.onWillPop,
    this.canPop = true,
  }) : super(key: key);

  @override
  State<SafeBackHandler> createState() => _SafeBackHandlerState();
}

class _SafeBackHandlerState extends State<SafeBackHandler> {
  @override
  Widget build(BuildContext context) {
    // Gunakan PopScope untuk Flutter 3.12+
    // Fallback ke WillPopScope untuk Flutter 3.11 dan sebelumnya
    return PopScope(
      canPop: widget.canPop && Navigator.canPop(context),
      onPopInvoked: (didPop) {
        if (!didPop && Navigator.canPop(context)) {
          widget.onWillPop?.call();
          Navigator.pop(context);
        } else if (!didPop) {
          // Stack kosong, arahkan ke home
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/',
            (route) => false,
          );
        }
      },
      child: widget.child,
    );
  }
}

/// Safe AppBar back button builder
class SafeBackButton extends StatelessWidget {
  final BuildContext context;
  final VoidCallback? onPressed;
  final String routeName;
  final Color? color;
  final IconData icon;
  final double? size;

  const SafeBackButton({
    Key? key,
    required this.context,
    this.onPressed,
    this.routeName = '/',
    this.color,
    this.icon = Icons.arrow_back_rounded,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: color),
      iconSize: size,
      onPressed: () {
        onPressed?.call();
        NavigationUtils.safeBack(context, routeName: routeName);
      },
    );
  }
}

/// Safe leading widget untuk AppBar
Widget buildSafeBackButton(
  BuildContext context, {
  VoidCallback? onPressed,
  String routeName = '/',
  Color? color,
  IconData icon = Icons.arrow_back_rounded,
  double? size,
}) {
  return IconButton(
    icon: Icon(icon, color: color),
    iconSize: size,
    onPressed: () {
      onPressed?.call();
      NavigationUtils.safeBack(context, routeName: routeName);
    },
  );
}

/// Safe leading widget dengan explicit canPop check
Widget buildSafeBackButtonWithCheck(
  BuildContext context, {
  VoidCallback? onPressed,
  String routeName = '/',
  Color? color,
  IconData icon = Icons.arrow_back_rounded,
  double? size,
}) {
  return IconButton(
    icon: Icon(icon, color: color),
    iconSize: size,
    onPressed: () {
      onPressed?.call();
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          routeName,
          (route) => false,
        );
      }
    },
  );
}
