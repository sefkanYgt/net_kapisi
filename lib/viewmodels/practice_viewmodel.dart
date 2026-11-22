import 'package:flutter/foundation.dart';

import '../core/utils.dart';
import '../models/test_record.dart';
import '../services/gemini_service.dart';
import 'tests_viewmodel.dart';

/// 2. sayfa: Soru üretimi (20 soru)
class PracticeViewModel extends ChangeNotifier {
  final GeminiService _gemini;
  PracticeViewModel(this._gemini);

  String? lesson;
  String? topic;
  bool explanations = true;
  bool loading = false;
  String? error;

  void selectLesson(String? v) {
    lesson = v;
    topic = null;
    notifyListeners();
  }

  void selectTopic(String? v) {
    topic = v;
    notifyListeners();
  }

  /// Seviye sayfasından "Soru üret" ile gelince ders + konu hazır seçilir.
  void select(String l, String t) {
    lesson = l;
    topic = t;
    notifyListeners();
  }

  void setExplanations(bool v) {
    explanations = v;
    notifyListeners();
  }

  /// 20 soru üretir, arşive kaydeder ve kaydı döner.
  Future<TestRecord?> generate(String field, TestsViewModel tests) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final level = tests.levelOf(field, lesson!, topic!) ?? Levels.medium;
      final qs = await _gemini.generate(
        field: field,
        lesson: lesson!,
        topic: topic!,
        counts: Levels.distribution(level),
      );
      final r = TestRecord.create(
        field: field,
        lesson: lesson!,
        topic: topic!,
        kind: 'practice',
        level: level,
        questions: qs,
      );
      tests.addRecord(r);
      return r;
    } on GeminiException catch (e) {
      debugPrint('SORU URETME HATASI (Gemini): ${e.message}');
      error = e.message;
      return null;
    } catch (e) {
      debugPrint('SORU URETME HATASI: $e');
      error = 'Soru üretilemedi. İnternet bağlantını kontrol et.';
      return null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}