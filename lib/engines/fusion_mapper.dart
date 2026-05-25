import '../models/meihua/meihua_result.dart';

/// 梅花易数 → 塔罗 映射逻辑
class FusionMapper {
  /// 八卦五行 → 塔罗牌组
  static const _elementToSuit = {
    '火': 'wands',   // 权杖
    '土': 'pentacles', // 星币
    '木': 'swords',  // 宝剑
    '水': 'cups',    // 圣杯
    '金': null,      // 金性刚坚，视上下文
  };

  /// 体用生克 → 塔罗抽取策略
  static Map<String, dynamic> getTarotStrategy(String tiYongRelation) {
    switch (tiYongRelation) {
      case '用生体':
        return {'suit': 'wands', 'preferMajor': false, 'desc': '外部生助，宜积极进取'};
      case '体用比和':
        return {'suit': null, 'preferMajor': false, 'desc': '内外和谐，顺其自然'}; // cups+pentacles
      case '体克用':
        return {'suit': 'swords', 'preferMajor': false, 'desc': '需用智慧克服困难'};
      case '体生用':
        return {'suit': 'pentacles', 'preferMajor': false, 'desc': '付出才有回报，宜务实'};
      case '用克体':
        return {'suit': 'major', 'preferMajor': true, 'desc': '面临重大课题，需审慎'};
      default:
        return {'suit': null, 'preferMajor': false, 'desc': '顺其自然'};
    }
  }

  /// 动爻位置 → 塔罗牌阵聚焦位置
  /// 动爻1-2→过去(0), 3-4→现在(1), 5-6→未来(2)
  static int movingYaoToFocusPosition(int movingYaoPos) {
    if (movingYaoPos <= 2) return 0;
    if (movingYaoPos <= 4) return 1;
    return 2;
  }

  /// 根据卦象五行获取塔罗牌组过滤
  static String? getSuitFilter(MeihuaResult result, Map<String, dynamic> strategy) {
    final suit = strategy['suit'] as String?;
    if (suit != null && suit != 'major') return suit;
    if (suit == 'major') return null; // major 由 preferMajor 控制
    // 比和时，看卦象五行
    final tiElement = result.tiYong.tiElement;
    return _elementToSuit[tiElement];
  }
}
