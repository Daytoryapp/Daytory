import 'package:date_app/src/app.dart';
import 'package:date_app/src/data/date_log_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await DateLogRepository.init();
  await Hive.openBox<Map>('user_profile');
  KakaoSdk.init(nativeAppKey: 'a15f2d949751205b32c6d31a315d8ae4');
  runApp(const ProviderScope(child: DateApp()));
}
