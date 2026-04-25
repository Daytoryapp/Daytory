import 'package:flutter/material.dart';

class AppConstants {
  static const double defaultLatitude = 37.5665;
  static const double defaultLongitude = 126.9780;
  static const double defaultMapZoom = 11.0;

  static const int minMoodScore = 1;
  static const int maxMoodScore = 5;

  static const String osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String userAgentPackage = 'com.example.date_app';

  // Spacing
  static const double spaceXS = 4.0;
  static const double spaceS = 8.0;
  static const double spaceM = 16.0;
  static const double spaceL = 24.0;
  static const double spaceXL = 32.0;

  // Border radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;

  // Colors
  static const Color pink = Color(0xFFFF4D8D);
  static const Color pinkLight = Color(0xFFFFE4EF);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF8A8A9A);
  static const Color surface = Color(0xFFF6F6F9);
  static const Color border = Color(0xFFEEEEF2);

  // Mood
  static const List<String> moodEmojis = ['', '😢', '😕', '😊', '🥰', '💕'];
  static const List<String> moodLabels = ['', '별로', '그냥', '좋아', '설레', '최고'];
  static const List<Color> moodColors = [
    Colors.transparent,
    Color(0xFFBFDBFE),
    Color(0xFFE9D5FF),
    Color(0xFFFEF08A),
    Color(0xFFBBF7D0),
    Color(0xFFFFE4EF),
  ];
}
