import 'package:flutter/material.dart';
import 'theme.dart';
import '../pages/home/home_page.dart';
import '../pages/meihua/input_page.dart' as meihua_input;
import '../pages/meihua/result_page.dart' as meihua_result;
import '../pages/tarot/prepare_page.dart' as tarot_prepare;
import '../pages/tarot/flip_page.dart' as tarot_flip;
import '../pages/tarot/reading_page.dart' as tarot_reading;
import '../pages/fusion/input_page.dart' as fusion_input;
import '../pages/fusion/hexagram_page.dart' as fusion_hexagram;
import '../pages/fusion/flip_page.dart' as fusion_flip;
import '../pages/fusion/reading_page.dart' as fusion_reading;
import '../pages/bazi/input_page.dart' as bazi_input;
import '../pages/bazi/result_page.dart' as bazi_result;
import '../pages/history/list_page.dart' as history_list;
import '../pages/history/detail_page.dart' as history_detail;
import '../pages/settings/settings_page.dart' as settings_page;
import '../models/meihua/meihua_result.dart';
import '../models/fusion_result.dart';
import '../models/bazi/bazi_result.dart';
import '../models/history_record.dart';

class LingXiTianJiApp extends StatelessWidget {
  const LingXiTianJiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '灵犀天机',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomePage(),
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // 梅花易数
      case '/meihua':
        return MaterialPageRoute(
          builder: (_) => const meihua_input.MeihuaInputPage(),
          settings: settings,
        );
      case '/meihua/result':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => meihua_result.MeihuaResultPage(
            result: args['result'] as MeihuaResult,
            question: args['question'] as String?,
          ),
          settings: settings,
        );
      // 塔罗占卜
      case '/tarot':
        return MaterialPageRoute(
          builder: (_) => const tarot_prepare.TarotPreparePage(),
          settings: settings,
        );
      case '/tarot/flip':
        return MaterialPageRoute(
          builder: (_) => const tarot_flip.TarotFlipPage(),
          settings: settings,
        );
      case '/tarot/reading':
        return MaterialPageRoute(
          builder: (_) => const tarot_reading.TarotReadingPage(),
          settings: settings,
        );
      // 融合占卜
      case '/fusion':
        return MaterialPageRoute(
          builder: (_) => const fusion_input.FusionInputPage(),
          settings: settings,
        );
      case '/fusion/hexagram':
        final hexArgs = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => fusion_hexagram.FusionHexagramPage(
            meihuaResult: hexArgs['result'] as MeihuaResult,
            question: hexArgs['question'] as String?,
          ),
          settings: settings,
        );
      case '/fusion/flip':
        return MaterialPageRoute(
          builder: (_) => fusion_flip.FusionFlipPage(
            fusionResult: settings.arguments as FusionResult,
          ),
          settings: settings,
        );
      case '/fusion/reading':
        return MaterialPageRoute(
          builder: (_) => fusion_reading.FusionReadingPage(
            fusionResult: settings.arguments as FusionResult,
          ),
          settings: settings,
        );
      // 八字命理
      case '/bazi':
        return MaterialPageRoute(
          builder: (_) => const bazi_input.BaziInputPage(),
          settings: settings,
        );
      case '/bazi/result':
        return MaterialPageRoute(
          builder: (_) => bazi_result.BaziResultPage(
            result: settings.arguments as BaziResult,
          ),
          settings: settings,
        );
      case '/history':
        return MaterialPageRoute(
          builder: (_) => const history_list.HistoryListPage(),
          settings: settings,
        );
      case '/history/detail':
        return MaterialPageRoute(
          builder: (_) => history_detail.HistoryDetailPage(
            record: settings.arguments as HistoryRecord,
          ),
          settings: settings,
        );
      case '/settings':
        return MaterialPageRoute(
          builder: (_) => const settings_page.SettingsPage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const _PlaceholderPage(),
          settings: settings,
        );
    }
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('开发中')),
      body: const Center(child: Text('页面开发中')),
    );
  }
}
