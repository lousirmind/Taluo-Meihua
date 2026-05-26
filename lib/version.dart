/// 集中版本管理
/// 更新版本时只需修改此文件 + pubspec.yaml + android/app/build.gradle.kts
class AppVersion {
  AppVersion._();

  /// 展示给用户的版本名
  static const String name = '1.0.4';

  /// 内部版本号（Android versionCode）
  static const int code = 5;

  /// 带 v 前缀的显示字符串
  static const String display = 'v$name';
}
