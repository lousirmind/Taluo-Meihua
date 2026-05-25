import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../data/secure_storage.dart';
import '../../data/database/history_dao.dart';
import '../../services/llm_service.dart';
import '../../services/deepseek_service.dart';
import '../../version.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _keyCtrl = TextEditingController();
  bool _saving = false;
  bool _testing = false;
  String? _testResult;

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadKey() async {
    final key = await SecureStorage.readApiKey();
    if (key != null) _keyCtrl.text = key;
  }

  Future<void> _saveKey() async {
    setState(() => _saving = true);
    final key = _keyCtrl.text.trim();
    if (key.isEmpty) {
      await SecureStorage.deleteApiKey();
    } else {
      await SecureStorage.saveApiKey(key);
      LlmService.configure(DeepseekLlmService());
    }
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(key.isEmpty ? 'API Key 已清除' : 'API Key 已保存')),
      );
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _testing = true;
      _testResult = null;
    });
    final key = _keyCtrl.text.trim();
    if (key.isEmpty) {
      setState(() {
        _testResult = '请先输入 API Key';
        _testing = false;
      });
      return;
    }
    try {
      final response = await http.post(
        Uri.parse('https://api.deepseek.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $key',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {'role': 'user', 'content': 'Hello'},
          ],
          'max_tokens': 10,
        }),
      );
      if (response.statusCode == 200) {
        setState(() => _testResult = '✅ API 连接成功');
      } else {
        setState(() => _testResult = '❌ 连接失败 (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      setState(() => _testResult = '❌ 连接失败: $e');
    } finally {
      setState(() => _testing = false);
    }
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清除历史记录'),
        content: const Text('确定要删除所有历史记录吗？此操作不可恢复。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('确定清除', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await HistoryDao.clearAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('历史记录已清除')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // API 配置
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DeepSeek API 配置', style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary)),
                  const SizedBox(height: 4),
                  Text('输入你的 DeepSeek API Key 以启用 AI 解读功能',
                    style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.6))),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _keyCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'API Key',
                      hintText: 'sk-xxxxxxxxxxxxxxxx',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: _saving ? null : _saveKey,
                          child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('保存'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _testing ? null : _testConnection,
                          child: _testing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('测试连接'),
                        ),
                      ),
                    ],
                  ),
                  if (_testResult != null) ...[
                    const SizedBox(height: 8),
                    Text(_testResult!, style: TextStyle(
                      fontSize: 13,
                      color: _testResult!.startsWith('✅') ? Colors.green : Colors.red,
                    )),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 数据管理
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_sweep),
                  title: const Text('清除历史记录'),
                  subtitle: const Text('删除所有保存的占卜记录'),
                  onTap: _clearHistory,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 关于
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('关于灵犀天机'),
                  subtitle: const Text(AppVersion.display),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
