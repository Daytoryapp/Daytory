import 'package:date_app/src/core/constants/app_constants.dart';
import 'package:date_app/src/core/theme/app_theme.dart';
import 'package:date_app/src/features/add/add_log_screen.dart';
import 'package:date_app/src/features/calendar/calendar_screen.dart';
import 'package:date_app/src/features/map/map_screen.dart';
import 'package:date_app/src/features/stats/stats_screen.dart';
import 'package:flutter/material.dart';

class DateApp extends StatelessWidget {
  const DateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '데이트 기록',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = [
    CalendarScreen(),
    MapScreen(),
    AddLogScreen(),
    StatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppConstants.border)),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: '캘린더'),
            NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: '지도'),
            NavigationDestination(icon: Icon(Icons.add_circle_outline), selectedIcon: Icon(Icons.add_circle), label: '기록'),
            NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: '통계'),
          ],
        ),
      ),
    );
  }
}
