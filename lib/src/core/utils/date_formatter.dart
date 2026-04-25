import 'package:intl/intl.dart';

final _date = DateFormat('yyyy.MM.dd');
final _dateTime = DateFormat('yyyy.MM.dd HH:mm');
final _monthYear = DateFormat('yyyy년 MM월');

String formatDate(DateTime dt) => _date.format(dt);
String formatDateTime(DateTime dt) => _dateTime.format(dt);
String formatMonthYear(DateTime dt) => _monthYear.format(dt);
