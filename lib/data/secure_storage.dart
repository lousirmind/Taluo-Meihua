import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _apiKeyKey = 'deepseek_api_key';
  static const _storage = FlutterSecureStorage();

  static Future<void> saveApiKey(String key) async {
    await _storage.write(key: _apiKeyKey, value: key);
  }

  static Future<String?> readApiKey() async {
    return await _storage.read(key: _apiKeyKey);
  }

  static Future<void> deleteApiKey() async {
    await _storage.delete(key: _apiKeyKey);
  }

  static Future<bool> hasApiKey() async {
    final key = await readApiKey();
    return key != null && key.isNotEmpty;
  }
}
