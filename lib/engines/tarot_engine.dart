import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/tarot/tarot_card.dart';
import '../models/tarot/tarot_spread.dart';

class TarotEngine {
  static List<TarotCard>? _allCards;

  /// 加载塔罗牌义库
  static Future<List<TarotCard>> loadCards() async {
    if (_allCards != null) return _allCards!;
    final jsonStr = await rootBundle.loadString('lib/data/tarot_cards.json');
    final list = jsonDecode(jsonStr) as List<dynamic>;
    _allCards = list.map((e) => TarotCard.fromJson(e as Map<String, dynamic>)).toList();
    return _allCards!;
  }

  /// 独立塔罗模式：从78张中随机抽取3张
  static Future<TarotSpread> drawRandom() async {
    final cards = await loadCards();
    final rng = Random();
    final shuffled = List<TarotCard>.from(cards)..shuffle(rng);
    final selected = shuffled.take(3).toList();

    return TarotSpread(
      positions: [
        TarotPosition(name: '过去', card: selected[0], isReversed: rng.nextBool(), focusWeight: 1),
        TarotPosition(name: '现在', card: selected[1], isReversed: rng.nextBool(), focusWeight: 1),
        TarotPosition(name: '未来', card: selected[2], isReversed: rng.nextBool(), focusWeight: 1),
      ],
    );
  }

  /// 融合模式：按卦象规则过滤后抽取
  /// [suitFilter] 可选牌组过滤，null=不过滤（全副牌）
  /// [preferMajor] 是否优先大阿卡纳
  /// [focusPosition] 动爻决定的聚焦位置 (0-2)
  static Future<TarotSpread> drawFiltered({
    String? suitFilter,
    bool preferMajor = false,
    int focusPosition = 1,
  }) async {
    final cards = await loadCards();
    final rng = Random();

    List<TarotCard> pool;
    if (preferMajor) {
      pool = cards.where((c) => c.suit == 'major').toList();
      if (pool.length < 3) {
        pool = cards;
      }
    } else if (suitFilter != null) {
      pool = cards.where((c) => c.suit == suitFilter).toList();
      if (pool.length < 3) {
        pool = cards;
      }
    } else {
      pool = cards;
    }

    final shuffled = List<TarotCard>.from(pool)..shuffle(rng);
    final selected = shuffled.take(3).toList();

    return TarotSpread(
      positions: [
        TarotPosition(name: '过去', card: selected[0], isReversed: rng.nextBool(),
            focusWeight: focusPosition == 0 ? 2 : 1),
        TarotPosition(name: '现在', card: selected[1], isReversed: rng.nextBool(),
            focusWeight: focusPosition == 1 ? 2 : 1),
        TarotPosition(name: '未来', card: selected[2], isReversed: rng.nextBool(),
            focusWeight: focusPosition == 2 ? 2 : 1),
      ],
    );
  }
}
