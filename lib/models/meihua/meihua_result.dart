import 'hexagram.dart';
import 'trigram.dart';

class MovingYao {
  final int position;
  final bool originalIsYang;
  bool get changedIsYang => !originalIsYang;

  const MovingYao({
    required this.position,
    required this.originalIsYang,
  });
}

class TiYongAnalysis {
  final Trigram tiGua;
  final String tiElement;
  final Trigram yongGua;
  final String yongElement;
  final String relation; // 用生体 / 体用比和 / 体克用 / 体生用 / 用克体
  final String interpretation;

  const TiYongAnalysis({
    required this.tiGua,
    required this.tiElement,
    required this.yongGua,
    required this.yongElement,
    required this.relation,
    this.interpretation = '',
  });
}

class MeihuaResult {
  final Hexagram benGua;
  final Hexagram huGua;
  final Hexagram bianGua;
  final MovingYao movingYao;
  final TiYongAnalysis tiYong;
  final int number1;
  final int number2;
  final int number3;

  const MeihuaResult({
    required this.benGua,
    required this.huGua,
    required this.bianGua,
    required this.movingYao,
    required this.tiYong,
    required this.number1,
    required this.number2,
    required this.number3,
  });
}
