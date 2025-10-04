import 'package:flutter/services.dart';

/// 鸿蒙平台通道管理
class HarmonyOSChannel {
  static const MethodChannel _channel = MethodChannel('com.guozhigq.pilipala/harmonyos');
  
  /// 初始化鸿蒙平台通道
  static Future<void> initialize() async {
    try {
      await _channel.invokeMethod('initialize');
    } on PlatformException catch (e) {
      print('鸿蒙平台初始化失败: ${e.message}');
    }
  }
  
  /// 获取鸿蒙系统信息
  static Future<Map<String, dynamic>> getSystemInfo() async {
    try {
      final result = await _channel.invokeMethod('getSystemInfo');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      print('获取系统信息失败: ${e.message}');
      return {};
    }
  }
  
  /// 鸿蒙特有的分享功能
  static Future<bool> shareToHarmonyOS(String content, {String? title}) async {
    try {
      final result = await _channel.invokeMethod('share', {
        'content': content,
        'title': title,
      });
      return result == true;
    } on PlatformException catch (e) {
      print('鸿蒙分享失败: ${e.message}');
      return false;
    }
  }
  
  /// 鸿蒙通知功能
  static Future<bool> showHarmonyOSNotification(String title, String content) async {
    try {
      final result = await _channel.invokeMethod('showNotification', {
        'title': title,
        'content': content,
      });
      return result == true;
    } on PlatformException catch (e) {
      print('鸿蒙通知失败: ${e.message}');
      return false;
    }
  }
  
  /// 鸿蒙文件管理
  static Future<String?> getHarmonyOSFilesPath() async {
    try {
      final result = await _channel.invokeMethod('getFilesPath');
      return result;
    } on PlatformException catch (e) {
      print('获取鸿蒙文件路径失败: ${e.message}');
      return null;
    }
  }
  
  /// 鸿蒙权限管理
  static Future<bool> requestHarmonyOSPermission(String permission) async {
    try {
      final result = await _channel.invokeMethod('requestPermission', {
        'permission': permission,
      });
      return result == true;
    } on PlatformException catch (e) {
      print('鸿蒙权限请求失败: ${e.message}');
      return false;
    }
  }
}
