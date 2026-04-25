import 'package:date_app/src/app.dart';
import 'package:date_app/src/data/date_log_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await DateLogRepository.init();
  runApp(const ProviderScope(child: DateApp()));
}
