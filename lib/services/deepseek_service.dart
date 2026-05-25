import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/secure_storage.dart';
import 'llm_service.dart';
import '../models/fusion_result.dart';
import '../models/meihua/meihua_result.dart';
import '../models/tarot/tarot_spread.dart';
import '../models/bazi/bazi_result.dart';

/// DeepSeek API 实现的 LLM 解读服务
class DeepseekLlmService extends LlmService {
  static const _baseUrl = 'https://api.deepseek.com/v1/chat/completions';
  static const _model = 'deepseek-chat';

  String? _cachedKey;

  Future<String> _getApiKey() async {
    _cachedKey ??= await SecureStorage.readApiKey();
    return _cachedKey ?? '';
  }

  Future<String> _callDeepSeek(String systemPrompt, String userMessage) async {
    final apiKey = await _getApiKey();
    if (apiKey.isEmpty) {
      return '请先在设置中配置 DeepSeek API Key。';
    }

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userMessage},
          ],
          'max_tokens': 2000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else {
        return 'API 调用失败（${response.statusCode}）：${response.body}';
      }
    } catch (e) {
      return '网络请求失败：$e\n请检查网络连接后重试。';
    }
  }

  // ---- 系统提示词 ----
  static const _fusionSystemPrompt = '''
你是一位精通中西占卜学的解读师，擅长将梅花易数与塔罗牌结合起来进行综合解读。
你的解读风格：专业、深邃、中肯，不夸大不恐吓，保持严肃占卜的调性。
解读结构：
1. 宏观趋势：基于梅花卦象分析整体能量走向
2. 微观细节：基于塔罗牌面分析具体领域情况
3. 体用关系：解释体用生克带来的吉凶提示
4. 综合建议：将两种体系合拢给出建议
注意：明确标注"以上解读仅供娱乐参考，请理性看待。"
''';

  static const _meihuaSystemPrompt = '''
你是一位精通梅花易数的解读师。
解读需包含：卦象含义、体用生克分析、动爻解读、综合提示。
保持专业、中肯的语调。结尾标注"仅供娱乐参考"。
''';

  static const _tarotSystemPrompt = '''
你是一位专业的塔罗解读师，使用经典韦特塔罗体系。
解读需包含：三牌综合含义、正逆位影响、位置关联、综合建议。
保持专业、中肯。结尾标注"仅供娱乐参考"。
''';

  static const _baziSystemPrompt = '''
你是一位精通子平八字的命理师。
解读需包含：日主分析、四柱格局、五行旺衰、十神配置、大运走势、流年提示。
语言通俗易懂，专业术语附带解释。结尾标注"仅供娱乐参考"。
''';

  @override
  Future<String> getFusionReading(FusionResult result) async {
    final m = result.meihua;
    final t = result.tarot;
    final msg = '''
【梅花卦象】
本卦：${m.benGua.name}
卦辞：${m.benGua.guaCi}（${m.benGua.guaCiTranslation}）
体用：${m.tiYong.relation}（体卦${m.tiYong.tiGua.name}${m.tiYong.tiElement}，用卦${m.tiYong.yongGua.name}${m.tiYong.yongElement}）
动爻：第${m.movingYao.position}爻
变卦：${m.bianGua.name}

【塔罗牌面】
${t.positions.map((p) => '${p.name}：${p.card.name}（${p.isReversed ? "逆位" : "正位"}）\n牌义：${p.isReversed ? p.card.meaningDown : p.card.meaningUp}').join('\n\n')}

请给出融合以上两种体系的综合解读。
''';
    return _callDeepSeek(_fusionSystemPrompt, msg);
  }

  @override
  Future<String> getMeihuaReading(MeihuaResult result) async {
    final msg = '''
本卦：${result.benGua.name}
卦辞：${result.benGua.guaCi}（${result.benGua.guaCiTranslation}）
互卦：${result.huGua.name}
变卦：${result.bianGua.name}
动爻：第${result.movingYao.position}爻（${result.movingYao.originalIsYang ? "阳" : "阴"}变${result.movingYao.changedIsYang ? "阳" : "阴"}）
体用：${result.tiYong.relation}
体卦：${result.tiYong.tiGua.name}（${result.tiYong.tiElement}）
用卦：${result.tiYong.yongGua.name}（${result.tiYong.yongElement}）

请给出完整的梅花易数卦象解读。
''';
    return _callDeepSeek(_meihuaSystemPrompt, msg);
  }

  @override
  Future<String> getTarotReading(TarotSpread spread) async {
    final msg = '''
牌阵：过去-现在-未来
${spread.positions.map((p) => '【${p.name}】${p.card.name}（${p.isReversed ? "逆位" : "正位"}）\n牌义：${p.isReversed ? p.card.meaningDown : p.card.meaningUp}\n关键词：${p.card.keyword}').join('\n\n')}

请给出完整的三牌阵塔罗解读。
''';
    return _callDeepSeek(_tarotSystemPrompt, msg);
  }

  @override
  Future<String> getBaziReading(BaziResult result) async {
    final msg = '''
日主：${result.dayMaster}（${result.dayMasterElement}）
四柱：
年柱：${result.yearPillar.heavenlyStem}${result.yearPillar.earthlyBranch}（藏干：${result.yearPillar.hiddenStems.join("、")}，十神：${result.yearPillar.tenGods.join("、")}，纳音：${result.yearPillar.nayin}）
月柱：${result.monthPillar.heavenlyStem}${result.monthPillar.earthlyBranch}（藏干：${result.monthPillar.hiddenStems.join("、")}，十神：${result.monthPillar.tenGods.join("、")}，纳音：${result.monthPillar.nayin}）
日柱：${result.dayPillar.heavenlyStem}${result.dayPillar.earthlyBranch}（藏干：${result.dayPillar.hiddenStems.join("、")}，十神：${result.dayPillar.tenGods.join("、")}，纳音：${result.dayPillar.nayin}）
时柱：${result.hourPillar.heavenlyStem}${result.hourPillar.earthlyBranch}（藏干：${result.hourPillar.hiddenStems.join("、")}，十神：${result.hourPillar.tenGods.join("、")}，纳音：${result.hourPillar.nayin}）
空亡：${result.kongWang.join("、")}
起运年龄：${result.startAge}岁
当前大运：${result.daYunList.where((d) => d.isCurrent).map((d) => '${d.heavenlyStem}${d.earthlyBranch}（${d.startAge}-${d.endAge}岁）').join("、")}
流年：${result.currentYear.year}年 ${result.currentYear.heavenlyStem}${result.currentYear.earthlyBranch}（${result.currentYear.nayin}）

请给出完整的八字命理解读，包含整体运势、性格分析、五行分析、大运走势。
''';
    return _callDeepSeek(_baziSystemPrompt, msg);
  }
}
