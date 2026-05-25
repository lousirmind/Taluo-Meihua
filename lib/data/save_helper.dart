import 'database/history_dao.dart';
import '../models/history_record.dart';

/// 便捷保存占卜结果的工具方法
class SaveHelper {
  static Future<HistoryRecord> saveFusion({
    required Map<String, dynamic> hexagramData,
    required List<Map<String, dynamic>> tarotCards,
    required String? question,
    String? reading,
  }) {
    return HistoryDao.save(
      type: DivinationType.fusion,
      summary: question ?? hexagramData['name'] as String? ?? '融合占卜',
      jsonData: {
        'hexagram': hexagramData,
        'tarotCards': tarotCards,
        'question': question ?? '',
        'reading': reading ?? '',
      },
    );
  }

  static Future<HistoryRecord> saveMeihua(Map<String, dynamic> hexagramData, {String? question, String? reading}) {
    return HistoryDao.save(
      type: DivinationType.meihua,
      summary: question ?? hexagramData['name'] as String? ?? '梅花占卜',
      jsonData: {
        ...hexagramData,
        if (question != null && question.isNotEmpty) 'question': question,
        if (reading != null && reading.isNotEmpty) 'reading': reading,
      },
    );
  }

  static Future<HistoryRecord> saveTarot(List<Map<String, dynamic>> cards, {String? question, String? reading}) {
    return HistoryDao.save(
      type: DivinationType.tarot,
      summary: question ?? cards.map((c) => c['name'] as String).join('·'),
      jsonData: {
        'cards': cards,
        if (question != null && question.isNotEmpty) 'question': question,
        if (reading != null && reading.isNotEmpty) 'reading': reading,
      },
    );
  }

  static Future<HistoryRecord> saveBazi(Map<String, dynamic> baziData, {String? reading}) {
    return HistoryDao.save(
      type: DivinationType.bazi,
      summary: '${baziData['dayMaster']}日主 · ${baziData['yearPillar']?['heavenlyStem']}${baziData['yearPillar']?['earthlyBranch']}年',
      jsonData: {
        ...baziData,
        if (reading != null && reading.isNotEmpty) 'reading': reading,
      },
    );
  }

  /// 编码 MeihuaResult 为 JSON
  static Map<String, dynamic> encodeMeihua(dynamic meihua) {
    return {
      'name': meihua.benGua.name,
      'sequence': meihua.benGua.sequence,
      'guaCi': meihua.benGua.guaCi,
      'upperSymbol': meihua.benGua.upperSymbol,
      'lowerSymbol': meihua.benGua.lowerSymbol,
      'huGua': meihua.huGua.name,
      'bianGua': meihua.bianGua.name,
      'movingYao': meihua.movingYao.position,
      'tiYong': {
        'relation': meihua.tiYong.relation,
        'tiGua': meihua.tiYong.tiGua.name,
        'yongGua': meihua.tiYong.yongGua.name,
        'tiElement': meihua.tiYong.tiElement,
        'yongElement': meihua.tiYong.yongElement,
      },
    };
  }

  /// 编码 TarotSpread 为 JSON
  static List<Map<String, dynamic>> encodeTarot(dynamic spread) {
    return (spread.positions as List).map((p) => {
      'position': p.name,
      'name': p.card.name,
      'nameEn': p.card.nameEn,
      'suit': p.card.suit,
      'isReversed': p.isReversed,
      'meaning': p.isReversed ? p.card.meaningDown : p.card.meaningUp,
      'keyword': p.card.keyword,
    }).toList().cast<Map<String, dynamic>>();
  }

  /// 编码 BaziResult 为 JSON
  static Map<String, dynamic> encodeBazi(dynamic result) {
    return {
      'dayMaster': result.dayMaster,
      'dayMasterElement': result.dayMasterElement,
      'yearPillar': result.yearPillar.toJson(),
      'monthPillar': result.monthPillar.toJson(),
      'dayPillar': result.dayPillar.toJson(),
      'hourPillar': result.hourPillar.toJson(),
      'kongWang': result.kongWang,
      'startAge': result.startAge,
      'currentYear': result.currentYear.toJson(),
    };
  }
}
