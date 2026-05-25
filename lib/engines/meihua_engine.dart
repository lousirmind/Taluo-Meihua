import 'dart:math';
import '../data/constants/hexagrams.dart';
import '../models/meihua/meihua_result.dart';
import '../models/meihua/hexagram.dart';
import '../models/meihua/trigram.dart';

class MeihuaEngine {
  static int _remap(int n, int mod) {
    final r = n % mod;
    return r == 0 ? mod : r;
  }

  /// 3位二进制模式(bit2下=bottom, bit0上=top) → 先天八卦数(1-8)
  static int _binaryToTrigramNumber(int bits) {
    return bits == 0 ? 8 : 8 - bits;
  }

  /// 主入口：输入3个数字，计算完整梅花结果
  static MeihuaResult calculate(int n1, int n2, int n3) {
    final upperNum = _remap(n1, 8); // 1-8
    final lowerNum = _remap(n2, 8); // 1-8
    final movingYaoPos = _remap(n3, 6); // 1-6

    final upperTri = Trigram.fromNumber(upperNum);
    final lowerTri = Trigram.fromNumber(lowerNum);

    final benGua = _buildHexagram(upperNum, lowerNum, '本卦');
    final huGua = _buildHuGua(benGua);
    final bianGua = _buildBianGua(benGua, movingYaoPos);

    final originalLines = _linesFor(benGua);
    final movingYao = MovingYao(
      position: movingYaoPos,
      originalIsYang: originalLines[movingYaoPos - 1] == 1,
    );

    final tiYong = _analyzeTiYong(upperTri, lowerTri, movingYaoPos);

    return MeihuaResult(
      benGua: benGua,
      huGua: huGua,
      bianGua: bianGua,
      movingYao: movingYao,
      tiYong: tiYong,
      number1: n1,
      number2: n2,
      number3: n3,
    );
  }

  static Hexagram _buildHexagram(int upperNum, int lowerNum, String label) {
    final upperName = Trigram.fromNumber(upperNum).name;
    final lowerName = Trigram.fromNumber(lowerNum).name;

    final seq = HexagramsData.findSequence(upperName, lowerName) ?? 1;
    final entry = HexagramsData.getHexagram(seq);

    final lines = List.generate(6, (i) {
      final bit = (entry.linesMask >> (5 - i)) & 1;
      return Yao(position: i + 1, isYang: bit == 1);
    });

    return Hexagram(
      name: entry.name,
      sequence: seq,
      upperName: upperName,
      lowerName: lowerName,
      lines: lines,
      guaCi: entry.guaCi,
      guaCiTranslation: entry.translation,
    );
  }

  /// 取六爻列表（从下到上，0=初爻）
  static List<int> _linesFor(Hexagram h) {
    return h.lines.map((y) => y.isYang ? 1 : 0).toList();
  }

  /// 构建互卦
  static Hexagram _buildHuGua(Hexagram benGua) {
    final lines = _linesFor(benGua);
    // 下互: 2,3,4爻; 上互: 3,4,5爻 (bit2=bottom, bit1=middle, bit0=top)
    final lowerBits = (lines[1] << 2) | (lines[2] << 1) | lines[3];
    final upperBits = (lines[2] << 2) | (lines[3] << 1) | lines[4];
    return _buildHexagram(_binaryToTrigramNumber(upperBits), _binaryToTrigramNumber(lowerBits), '互卦');
  }

  /// 构建变卦
  static Hexagram _buildBianGua(Hexagram benGua, int movingPos) {
    final lines = List<int>.from(_linesFor(benGua));
    lines[movingPos - 1] = 1 - lines[movingPos - 1]; // 阴阳互变

    // 下卦: 1,2,3爻; 上卦: 4,5,6爻 (bit2=bottom, bit1=middle, bit0=top)
    final lowerBits = (lines[0] << 2) | (lines[1] << 1) | lines[2];
    final upperBits = (lines[3] << 2) | (lines[4] << 1) | lines[5];
    return _buildHexagram(_binaryToTrigramNumber(upperBits), _binaryToTrigramNumber(lowerBits), '变卦');
  }

  /// 分析体用生克
  static TiYongAnalysis _analyzeTiYong(Trigram upper, Trigram lower, int movingYaoPos) {
    final yongInUpper = movingYaoPos >= 4; // 4-6爻动→用为上卦
    final yongGua = yongInUpper ? upper : lower;
    final tiGua = yongInUpper ? lower : upper;

    final relation = _getTiYongRelation(tiGua.element, yongGua.element);

    return TiYongAnalysis(
      tiGua: tiGua,
      tiElement: tiGua.element,
      yongGua: yongGua,
      yongElement: yongGua.element,
      relation: relation,
      interpretation: _tiYongInterpretation(relation),
    );
  }

  static String _getTiYongRelation(String tiElement, String yongElement) {
    const sheng = {'木': '火', '火': '土', '土': '金', '金': '水', '水': '木'};
    const ke = {'木': '土', '土': '水', '水': '火', '火': '金', '金': '木'};

    if (tiElement == yongElement) return '体用比和';
    if (sheng[yongElement] == tiElement) return '用生体';
    if (sheng[tiElement] == yongElement) return '体生用';
    if (ke[tiElement] == yongElement) return '体克用';
    if (ke[yongElement] == tiElement) return '用克体';
    return '体用比和';
  }

  static final _interpretations = {
    '用生体': '大吉之象。外部环境生助自身，事易成，有贵人相助，一切顺利。',
    '体用比和': '吉象。主客和谐，双方相合，事情顺利发展，无往不利。',
    '体克用': '小吉之象。自身可克制外部环境，需付出努力但终能成功。',
    '体生用': '小凶之象。自身力量被外部消耗，付出多而回报少，需注意量力而行。',
    '用克体': '大凶之象。外部环境压制自身，事不可为，宜退守观察，不可冒进。',
  };

  static String _tiYongInterpretation(String relation) {
    return _interpretations[relation] ?? '';
  }

  /// 随机生成3个占卜数字
  static List<int> randomNumbers({int max = 9999}) {
    final rng = Random();
    return [rng.nextInt(max) + 1, rng.nextInt(max) + 1, rng.nextInt(max) + 1];
  }

  /// 根据当前时间起卦
  /// 年数 = 年地支序数, 月数 = 公历月, 日数 = 公历日, 时数 = 时辰序数
  static MeihuaResult timeBasedCalculate(DateTime now) {
    final yearGanIndex = (now.year - 4) % 12; // 0=子...11=亥
    final yearZhiNum = yearGanIndex + 1;       // 1-12
    final monthNum = now.month;                // 1-12
    final dayNum = now.day;                    // 1-31
    final hourNum = ((now.hour + 1) ~/ 2) % 12 + 1; // 时辰序数 1-12

    final upper = yearZhiNum + monthNum + dayNum;
    final lower = yearZhiNum + monthNum + dayNum + hourNum;
    final moving = lower;

    return calculate(upper, lower, moving);
  }
}
