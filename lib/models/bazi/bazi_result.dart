import 'pillar.dart';
import 'da_yun.dart';

class BaziInput {
  final int year;
  final int month;
  final int day;
  final int hour; // 0-23
  final String gender; // "male" | "female"
  final bool isLunar;
  final String? birthPlace;
  final double? longitude;

  const BaziInput({
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
    required this.gender,
    this.isLunar = false,
    this.birthPlace,
    this.longitude,
  });
}

class BaziResult {
  final Pillar yearPillar;
  final Pillar monthPillar;
  final Pillar dayPillar;
  final Pillar hourPillar;
  final String dayMaster;
  final String dayMasterElement;
  final List<String> kongWang;
  final double startAge;
  final List<DaYun> daYunList;
  final LiuNian currentYear;
  final String llmInterpretation;

  const BaziResult({
    required this.yearPillar,
    required this.monthPillar,
    required this.dayPillar,
    required this.hourPillar,
    required this.dayMaster,
    required this.dayMasterElement,
    this.kongWang = const [],
    this.startAge = 0,
    this.daYunList = const [],
    required this.currentYear,
    this.llmInterpretation = '',
  });
}
