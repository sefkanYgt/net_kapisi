import 'package:flutter/foundation.dart';

import '../core/curriculum.dart';
import '../models/test_record.dart';
import '../services/storage_service.dart';

class TopicStats {
  final int correct;
  final int wrong;
  final int blank;
  final int tests;
  const TopicStats(this.correct, this.wrong, this.blank, this.tests);
}

/// Seviyeleri ve tüm test kayıtlarını (arşiv) tutar.
class TestsViewModel extends ChangeNotifier {
  final StorageService _s;
  late Map<String, String> _levels;
  late List<TestRecord> _records;

  TestsViewModel(this._s) {
    _levels = _s.levels;
    _records = _s.records;
  }

  List<TestRecord> get records => List.unmodifiable(_records);

  String _key(String f, String l, String t) => '$f|$l|$t';

  String? levelOf(String field, String lesson, String topic) =>
      _levels[_key(field, lesson, topic)];

  void setLevel(String field, String lesson, String topic, String level) {
    _levels[_key(field, lesson, topic)] = level;
    _s.saveLevels(_levels);
    notifyListeners();
  }

  void addRecord(TestRecord r) {
    _records.insert(0, r);
    _s.saveRecords(_records);
    notifyListeners();
  }

  void updateRecord(TestRecord r) {
    _s.saveRecords(_records);
    notifyListeners();
  }

  bool _match(TestRecord r, String f, String l, String t) =>
      r.solved && r.field == f && r.lesson == l && r.topic == t;

  TopicStats statsOf(String field, String lesson, String topic) {
    var c = 0, w = 0, b = 0, n = 0;
    for (final r in _records) {
      if (_match(r, field, lesson, topic)) {
        c += r.correct;
        w += r.wrong;
        b += r.blank;
        n++;
      }
    }
    return TopicStats(c, w, b, n);
  }

  /// Bir konu, en az bir test çözüldüyse "bitti" sayılır.
  bool isCompleted(String field, String lesson, String topic) =>
      _records.any((r) => _match(r, field, lesson, topic));

  int completedCount(String field) => Curriculum.allTopicKeys(field)
      .where((k) => isCompleted(field, k[0], k[1]))
      .length;

  double progress(String field) {
    final total = Curriculum.totalTopics(field);
    return total == 0 ? 0 : completedCount(field) / total;
  }
}
