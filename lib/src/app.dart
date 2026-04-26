import 'package:date_app/src/core/constants/app_constants.dart';
import 'package:date_app/src/core/theme/app_theme.dart';
import 'package:date_app/src/features/add/add_log_screen.dart';
import 'package:date_app/src/features/auth/login_screen.dart';
import 'package:date_app/src/features/auth/profile_setup_screen.dart';
import 'package:date_app/src/features/calendar/calendar_screen.dart';
import 'package:date_app/src/features/map/map_screen.dart';
import 'package:date_app/src/features/mypage/mypage_screen.dart';
import 'package:date_app/src/features/stats/stats_screen.dart';
import 'package:date_app/src/state/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DateApp extends ConsumerWidget {
  const DateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);

    late final Widget home;
    switch (auth.status) {
      case AuthStatus.loading:
        home = const _SplashScreen();
      case AuthStatus.loggedOut:
        home = const LoginScreen();
      case AuthStatus.needsProfile:
        home = const ProfileSetupScreen();
      case AuthStatus.ready:
        home = const HomeShell();
    }

    return MaterialApp(
      title: 'DayStory',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: home,
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('💕', style: TextStyle(fontSize: 64)),
            SizedBox(height: 16),
            Text(
              'DayStory',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppConstants.textPrimary,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
      ),
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
    MypageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppConstants.border))),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (v) => setState(() => _index = v),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month),
                label: '캘린더'),
            NavigationDestination(
                icon: Icon(Icons.map_outlined),
                selectedIcon: Icon(Icons.map),
                label: '지도'),
            NavigationDestination(
                icon: Icon(Icons.add_circle_outline),
                selectedIcon: Icon(Icons.add_circle),
                label: '기록'),
            NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart),
                label: '통계'),
            NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: '마이'),
          ],
        ),
      ),
    );
  }
}
