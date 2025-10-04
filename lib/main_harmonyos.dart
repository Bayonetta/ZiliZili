import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/platform/harmonyos_channel.dart';
import 'package:pilipala/pages/main/view.dart';
import 'package:pilipala/utils/storage.dart';

/// 鸿蒙版本主应用入口
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化鸿蒙平台通道
  await HarmonyOSChannel.initialize();
  
  // 初始化存储
  await GStrorage.init();
  
  // 获取鸿蒙系统信息
  final systemInfo = await HarmonyOSChannel.getSystemInfo();
  print('鸿蒙系统信息: $systemInfo');
  
  runApp(const PiliPalaHarmonyOSApp());
}

class PiliPalaHarmonyOSApp extends StatelessWidget {
  const PiliPalaHarmonyOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PiliPala 鸿蒙版',
      debugShowCheckedModeBanner: false,
      theme: _buildHarmonyOSTheme(),
      home: const MainApp(),
      // 鸿蒙特有配置
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            // 适配鸿蒙屏幕
            textScaleFactor: 1.0,
          ),
          child: child!,
        );
      },
    );
  }
  
  /// 构建鸿蒙主题
  ThemeData _buildHarmonyOSTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: const Color(0xFF007AFF), // 鸿蒙蓝色
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF007AFF),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Color(0xFF007AFF),
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007AFF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF007AFF)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      // 鸿蒙字体
      fontFamily: 'HarmonyOS Sans',
    );
  }
}

/// 鸿蒙平台检测
class HarmonyOSPlatform {
  static bool get isHarmonyOS {
    return Platform.isAndroid && 
           (Platform.environment['HARMONYOS'] == 'true' ||
            Platform.environment['HUAWEI'] == 'true');
  }
  
  static bool get isHarmonyOSNext {
    return isHarmonyOS && 
           (Platform.environment['HARMONYOS_VERSION']?.startsWith('4.') == true);
  }
}
