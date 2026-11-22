import 'package:flutter/foundation.dart';

import '../core/utils.dart';
import '../models/test_record.dart';
import '../services/gemini_service.dart';
import 'tests_viewmodel.dart';

/// 1. sayfa: Seviye belirleme (5 soru: 1 kolay, 2 orta, 2 zor)
class LevelViewModel extends ChangeNotifier {
  final GeminiService _gemini;
  LevelViewModel(this._gemini);

  String? lesson;
  String? topic;
  bool loading = false;
  String? error;
  String? resultLevel;
  int? resultCorrect;

  void selectLesson(String? v) {
    lesson = v;
    topic = null;
    resultLevel = null;
    notifyListeners();
  }

  void selectTopic(String? v) {
    topic = v;
    resultLevel = null;
    notifyListeners();
  }

  Future<TestRecord?> generate(String field) async {
    loading = true;
    error = null;
    resultLevel = null;
    notifyListeners();
    try {
      final qs = await _gemini.generate(
        field: field,
        lesson: lesson!,
        topic: topic!,
        counts: {Levels.easy: 1, Levels.medium: 2, Levels.hard: 2},
      );
      return TestRecord.create(
        field: field,
        lesson: lesson!,
        topic: topic!,
        kind: 'level',
        level: '',
        questions: qs,
      );
    } on GeminiException catch (e) {
      debugPrint('SEVIYE SORU HATASI (Gemini): ${e.message}');
      error = e.message;
      return null;
    } catch (e) {
      debugPrint('SEVIYE SORU HATASI: $e');
      error = 'Soru üretilemedi. İnternet bağlantını kontrol et.';
      return null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Test bitince çağrılır: seviyeyi belirler, kaydeder, arşive ekler.
  void complete(TestRecord r, TestsViewModel tests) {
    final level = Levels.fromCorrect(r.correct);
    r.level = level;
    resultLevel = level;
    resultCorrect = r.correct;
    tests.setLevel(r.field, r.lesson, r.topic, level);
    tests.addRecord(r);
    notifyListeners();
  }
}