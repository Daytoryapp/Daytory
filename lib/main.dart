import 'package:date_app/src/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Hive.initFlutter();

  // 구버전 로컬 date_logs 박스 제거 (Supabase로 이전)
  if (await Hive.boxExists('date_logs')) {
    final box = await Hive.openBox<Map>('date_logs');
    await box.clear();
    await box.close();
    await Hive.deleteBoxFromDisk('date_logs');
  }

  await Hive.openBox<Map>('user_profile');
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  KakaoSdk.init(nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY']!);
  runApp(const ProviderScope(child: DateApp()));
}
