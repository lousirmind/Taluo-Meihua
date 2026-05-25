enum DivinationType { fusion, meihua, tarot, bazi }

class HistoryRecord {
  final String id;
  final DivinationType type;
  final DateTime createTime;
  final String summary;
  final String? jsonData;

  const HistoryRecord({
    required this.id,
    required this.type,
    required this.createTime,
    this.summary = '',
    this.jsonData,
  });

  String get typeLabel {
    switch (type) {
      case DivinationType.fusion:
        return '融合占卜';
      case DivinationType.meihua:
        return '梅花易数';
      case DivinationType.tarot:
        return '塔罗占卜';
      case DivinationType.bazi:
        return '八字命理';
    }
  }
}
