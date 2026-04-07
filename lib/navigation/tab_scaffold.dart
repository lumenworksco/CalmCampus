import 'package:flutter/cupertino.dart';
import '../screens/dashboard_screen.dart';
import '../screens/insights_screen.dart';
import '../screens/interventions_screen.dart';
import '../screens/profile_screen.dart';
import '../theme/app_colors.dart';

class TabScaffold extends StatelessWidget {
  const TabScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        activeColor: AppColors.accent,
        inactiveColor: AppColors.textTertiary,
        backgroundColor: CupertinoColors.systemBackground.withValues(alpha: 0.92),
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        items: const [
          BottomNavigationBarItem(icon: Text('🏠', style: TextStyle(fontSize: 20)), label: 'Home'),
          BottomNavigationBarItem(icon: Text('📊', style: TextStyle(fontSize: 20)), label: 'Insights'),
          BottomNavigationBarItem(icon: Text('🌿', style: TextStyle(fontSize: 20)), label: 'Calm'),
          BottomNavigationBarItem(icon: Text('👤', style: TextStyle(fontSize: 20)), label: 'Profile'),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            switch (index) {
              case 0:
                return const DashboardScreen();
              case 1:
                return const InsightsScreen();
              case 2:
                return const InterventionsScreen();
              case 3:
                return const ProfileScreen();
              default:
                return const DashboardScreen();
            }
          },
        );
      },
    );
  }
}
