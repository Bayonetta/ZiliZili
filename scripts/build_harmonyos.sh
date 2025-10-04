#!/bin/bash

# 鸿蒙APK构建脚本
# 使用方法: ./scripts/build_harmonyos.sh [debug|release]

set -e

BUILD_TYPE=${1:-release}

echo "🚀 构建鸿蒙版PiliPala..."
echo "构建类型: $BUILD_TYPE"

# 检查Flutter环境
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter未安装，请先安装Flutter"
    exit 1
fi

# 检查鸿蒙环境
if ! flutter config --enable-harmonyos &> /dev/null; then
    echo "⚠️  鸿蒙支持可能未启用，尝试启用..."
    flutter config --enable-harmonyos
fi

# 清理项目
echo "🧹 清理项目..."
flutter clean

# 获取依赖
echo "📦 获取依赖..."
flutter pub get

# 生成必要文件
echo "🔧 生成必要文件..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# 构建鸿蒙版本
echo "📱 构建鸿蒙版本..."

if [ "$BUILD_TYPE" = "debug" ]; then
    echo "构建Debug版本..."
    flutter build apk --debug --target-platform android-arm64
elif [ "$BUILD_TYPE" = "release" ]; then
    echo "构建Release版本..."
    flutter build apk --release --target-platform android-arm64 --split-per-abi
else
    echo "❌ 无效的构建类型: $BUILD_TYPE"
    echo "使用方法: $0 [debug|release]"
    exit 1
fi

# 显示构建结果
echo "✅ 构建完成！"
echo "📁 APK文件位置:"
ls -la build/app/outputs/flutter-apk/

# 显示APK信息
echo "📊 APK信息:"
for apk in build/app/outputs/flutter-apk/*.apk; do
    if [ -f "$apk" ]; then
        echo "  - $(basename "$apk"): $(du -h "$apk" | cut -f1)"
    fi
done

echo "🎉 鸿蒙版构建完成！"
echo "💡 提示：APK文件已保存到 build/app/outputs/flutter-apk/ 目录"
echo "📱 可以在鸿蒙设备上安装测试"
