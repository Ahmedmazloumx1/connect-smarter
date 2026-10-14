import 'package:flutter/material.dart';
import 'company_dashboard_screen.dart';
import 'top_matched_candidates_screen.dart';
import 'manage_active_jobs_screen.dart';
import 'company_settings_screen.dart';

class CompanyBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CompanyBottomNavBar({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = const CompanyDashboardScreen();
        break;
      case 1:
        nextScreen = const TopMatchedCandidatesScreen();
        break;
      case 2:
        nextScreen = const ManageActiveJobsScreen();
        break;
      case 3:
        nextScreen = const CompanySettingsScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color activeColor = Color(0xFF1D2BFF);
    const Color inactiveColor = Color(0xFF8B8E9F);
    const Color bgColor = Color(0xFF0A0F24);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(
            color: const Color(0xFF1B2B4A).withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onItemTapped(context, index),
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: activeColor,
        unselectedItemColor: inactiveColor,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            activeIcon: Icon(Icons.search),
            label: 'Applicants',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
