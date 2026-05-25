class TenGods {
  static const matrix = {
    // 五行关系: 同我/我生/我克/克我/生我
    // 阴阳: 同/异
    '同我_同': '比肩',
    '同我_异': '劫财',
    '我生_同': '食神',
    '我生_异': '伤官',
    '我克_同': '偏财',
    '我克_异': '正财',
    '克我_同': '七杀',
    '克我_异': '正官',
    '生我_同': '偏印',
    '生我_异': '正印',
  };

  static const heavenlyStemElements = {
    '甲': '木', '乙': '木',
    '丙': '火', '丁': '火',
    '戊': '土', '己': '土',
    '庚': '金', '辛': '金',
    '壬': '水', '癸': '水',
  };

  static const heavenlyStemYang = {
    '甲': true, '乙': false,
    '丙': true, '丁': false,
    '戊': true, '己': false,
    '庚': true, '辛': false,
    '壬': true, '癸': false,
  };

  static const elementCycle = {
    '木': 0, '火': 1, '土': 2, '金': 3, '水': 4,
  };

  static const elementNames = ['木', '火', '土', '金', '水'];

  /// 判断目标天干相对于日干的十神
  static String getTenGod(String dayGan, String targetGan) {
    final dayElement = heavenlyStemElements[dayGan]!;
    final targetElement = heavenlyStemElements[targetGan]!;
    final dayIsYang = heavenlyStemYang[dayGan]!;
    final targetIsYang = heavenlyStemYang[targetGan]!;

    String relation;
    if (dayElement == targetElement) {
      relation = '同我';
    } else if (elementCycle[dayElement]! == (elementCycle[targetElement]! + 1) % 5) {
      relation = '生我';
    } else if (elementCycle[dayElement]! == (elementCycle[targetElement]! + 2) % 5) {
      relation = '克我';
    } else if ((elementCycle[dayElement]! + 1) % 5 == elementCycle[targetElement]!) {
      relation = '我生';
    } else {
      relation = '我克';
    }

    final sameYinYang = dayIsYang == targetIsYang;
    final key = '${relation}_${sameYinYang ? "同" : "异"}';
    return matrix[key]!;
  }
}
