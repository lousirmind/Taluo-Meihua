import '../models/fusion_result.dart';
import '../models/meihua/meihua_result.dart';
import '../models/tarot/tarot_spread.dart';
import '../models/bazi/bazi_result.dart';

/// LLM 解读服务抽象
abstract class LlmService {
  static LlmService instance = _PlaceholderService();

  /// 设置具体实现
  static void configure(LlmService service) => instance = service;

  Future<String> getFusionReading(FusionResult result, {String? question});
  Future<String> getMeihuaReading(MeihuaResult result, {String? question});
  Future<String> getTarotReading(TarotSpread spread, {String? question});
  Future<String> getBaziReading(BaziResult result, {String? question});
}

/// 占位实现 — 返回固定文本，待 DeepSeek API 集成后替换
class _PlaceholderService extends LlmService {
  @override
  Future<String> getFusionReading(FusionResult result, {String? question}) async {
    await Future.delayed(const Duration(seconds: 1));
    return '【融合占卜解读占位】\n\n'
        '梅花卦象：${result.meihua.benGua.name}\n'
        '体用关系：${result.meihua.tiYong.relation}\n\n'
        '塔罗牌面：${result.tarot.positions.map((p) => '${p.name} - ${p.card.name}(${p.isReversed ? "逆位" : "正位"})').join("、")}\n\n'
        '详细解读待 DeepSeek API 接入后生效。';
  }

  @override
  Future<String> getMeihuaReading(MeihuaResult result, {String? question}) async {
    await Future.delayed(const Duration(seconds: 1));
    return '【梅花易数解读占位】\n\n'
        '本卦：${result.benGua.name}\n'
        '体用：${result.tiYong.relation}\n'
        '${result.tiYong.interpretation}\n\n'
        '详细解读待 DeepSeek API 接入后生效。';
  }

  @override
  Future<String> getTarotReading(TarotSpread spread, {String? question}) async {
    await Future.delayed(const Duration(seconds: 1));
    return '【塔罗占卜解读占位】\n\n'
        '${spread.positions.map((p) => '【${p.name}】${p.card.name}(${p.isReversed ? "逆位" : "正位"})\n${p.isReversed ? p.card.meaningDown : p.card.meaningUp}').join("\n\n")}\n\n'
        '详细解读待 DeepSeek API 接入后生效。';
  }

  @override
  Future<String> getBaziReading(BaziResult result, {String? question}) async {
    await Future.delayed(const Duration(seconds: 1));
    return '【八字命理解读占位】\n\n'
        '日主：${result.dayMaster}（${result.dayMasterElement}）\n'
        '四柱：${result.yearPillar.heavenlyStem}${result.yearPillar.earthlyBranch} '
        '${result.monthPillar.heavenlyStem}${result.monthPillar.earthlyBranch} '
        '${result.dayPillar.heavenlyStem}${result.dayPillar.earthlyBranch} '
        '${result.hourPillar.heavenlyStem}${result.hourPillar.earthlyBranch}\n\n'
        '详细解读待 DeepSeek API 接入后生效。';
  }
}
