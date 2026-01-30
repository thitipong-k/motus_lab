import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:motus_lab/core/theme/app_style.dart';

class ThemeCubit extends Cubit<AppStyle> {
  // Default to Cyberpunk (Motus One)
  ThemeCubit() : super(AppStyle.cyberpunk) {
    _loadStyle();
  }

  /// **บันทึกธีมที่เลือกลงเครื่อง (Save)**
  Future<void> setStyle(AppStyle style) async {
    emit(style);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('app_style', style.index);
  }

  /// **โหลดธีมที่บันทึกไว้ (Load)**
  Future<void> _loadStyle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final index = prefs.getInt('app_style');
      if (index != null && index >= 0 && index < AppStyle.values.length) {
        emit(AppStyle.values[index]);
      }
    } catch (e) {
      debugPrint("Error loading theme: $e");
    }
  }
}
