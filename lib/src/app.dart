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
      title: "데이트 기록",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
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

  @override
  Widget build(BuildContext context) {
    final pages = const [
      CalendarScreen(),
      MapScreen(),
      AddLogScreen(),
      StatsScreen(),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) {
          setState(() {
            _index = value;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.calendar_month), label: "캘린더"),
          NavigationDestination(icon: Icon(Icons.map), label: "지도"),
          NavigationDestination(icon: Icon(Icons.add_circle), label: "기록 추가"),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: "통계"),
        ],
      ),
    );
  }
}
