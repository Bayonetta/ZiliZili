import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 鸿蒙风格组件
class HarmonyOSComponents {
  
  /// 鸿蒙风格按钮
  static Widget harmonyButton({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
    double? borderRadius,
    EdgeInsets? padding,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.blue,
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
          child: Container(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text(
              text,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
  
  /// 鸿蒙风格卡片
  static Widget harmonyCard({
    required Widget child,
    Color? backgroundColor,
    double? borderRadius,
    EdgeInsets? margin,
    EdgeInsets? padding,
    List<BoxShadow>? shadows,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        boxShadow: shadows ?? [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
  
  /// 鸿蒙风格输入框
  static Widget harmonyTextField({
    required String hintText,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
  
  /// 鸿蒙风格列表项
  static Widget harmonyListTile({
    required String title,
    String? subtitle,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
    Color? backgroundColor,
  }) {
    return Container(
      color: backgroundColor,
      child: ListTile(
        leading: leading,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: trailing,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
  
  /// 鸿蒙风格对话框
  static Future<void> showHarmonyDialog({
    required BuildContext context,
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(title),
        content: Text(content),
        actions: [
          if (cancelText != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onCancel?.call();
              },
              child: Text(cancelText),
            ),
          if (confirmText != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm?.call();
              },
              child: Text(confirmText),
            ),
        ],
      ),
    );
  }
  
  /// 鸿蒙风格加载指示器
  static Widget harmonyLoadingIndicator({
    Color? color,
    double? size,
  }) {
    return SizedBox(
      width: size ?? 24,
      height: size ?? 24,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color ?? Colors.blue),
        strokeWidth: 2,
      ),
    );
  }
}
