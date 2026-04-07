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
        backgroundColor:
            CupertinoColors.systemBackground.withValues(alpha: 0.94),
        border: Border(
            top: BorderSide(
                color: CupertinoColors.separator.withValues(alpha: 0.3),
                width: 0.5)),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.house_fill), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chart_bar_fill), label: 'Insights'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.leaf_arrow_circlepath), label: 'Calm'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person_fill), label: 'Profile'),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            final Widget screen;
            switch (index) {
              case 0:
                screen = const DashboardScreen();
              case 1:
                screen = const InsightsScreen();
              case 2:
                screen = const InterventionsScreen();
              case 3:
                screen = const ProfileScreen();
              default:
                screen = const DashboardScreen();
            }
            return CupertinoPageScaffold(
              backgroundColor: AppColors.background,
              child: screen,
            );
          },
        );
      },
    );
  }
}
