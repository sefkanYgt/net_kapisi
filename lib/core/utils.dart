import 'package:flutter/material.dart';

class Levels {
  static const String easy = 'kolay';
  static const String medium = 'orta';
  static const String hard = 'zor';

  /// 1-2 doğru: kolay, 3-4 doğru: orta, 5 doğru: zor (0 doğru da kolay sayılır)
  static String fromCorrect(int correct) {
    if (correct >= 5) return hard;
    if (correct >= 3) return medium;
    return easy;
  }

  static String label(String level) {
    if (level.isEmpty) return 'Belirlenmedi';
    return level[0].toUpperCase() + level.substring(1);
  }

  static Color color(String level) {
    switch (level) {
      case easy:
        return Colors.green;
      case medium:
        return Colors.orange;
      case hard:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// 20 soruluk testin zorluk dağılımı (seviyeye göre).
  static Map<String, int> distribution(String level) {
    switch (level) {
      case easy:
        return {easy: 12, medium: 6, hard: 2};
      case hard:
        return {easy: 2, medium: 6, hard: 12};
      default:
        return {easy: 4, medium: 12, hard: 4};
    }
  }
}

String fmtDate(DateTime d) {
  String t(int n) => n.toString().padLeft(2, '0');
  return '${t(d.day)}.${t(d.month)}.${d.year} ${t(d.hour)}:${t(d.minute)}';
}
