import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../theme/app_theme.dart';
import 'dashboard/dashboard_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _pageIndex = 0;
  
  // List of screens to navigate to
  final List<Widget> _screens = [
    const DashboardScreen(),
    const Center(child: Text("Calendar Screen (Coming Soon)")),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_pageIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: AppTheme.backgroundColor,
        color: AppTheme.surfaceColor,
        buttonBackgroundColor: AppTheme.primaryColor,
        height: 60,
        animationDuration: const Duration(milliseconds: 300),
        index: _pageIndex,
        items: [
          Icon(
            Icons.home_outlined,
            size: 30,
            color: _pageIndex == 0 ? Colors.white : AppTheme.slateGray,
          ),
          Icon(
            Icons.calendar_today_outlined,
            size: 30,
            color: _pageIndex == 1 ? Colors.white : AppTheme.slateGray,
          ),
          Icon(
            Icons.person_outline,
            size: 30,
            color: _pageIndex == 2 ? Colors.white : AppTheme.slateGray,
          ),
        ],
        onTap: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
      ),
    );
  }
}
