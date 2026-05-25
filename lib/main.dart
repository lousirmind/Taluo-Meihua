import 'package:flutter/material.dart';
import 'app/app.dart';
import 'data/secure_storage.dart';
import 'services/llm_service.dart';
import 'services/deepseek_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 检查是否有已保存的 API Key，有则激活 DeepSeek 服务
  final hasKey = await SecureStorage.hasApiKey();
  if (hasKey) {
    LlmService.configure(DeepseekLlmService());
  }

  runApp(const LingXiTianJiApp());
}
