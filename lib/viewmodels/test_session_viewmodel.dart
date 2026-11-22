import 'package:flutter/foundation.dart';

import '../models/test_record.dart';

/// Bir testi çözerken kullanılan geçici durum.
class TestSessionViewModel extends ChangeNotifier {
  final TestRecord record;
  late final List<int> answers;
  int index = 0;
  bool finished = false;

  TestSessionViewModel(this.record) {
    answers = List<int>.filled(record.questions.length, -1);
  }

  int get total => record.questions.length;
  int get blankCount => answers.where((a) => a < 0).length;

  /// Seçili şıkka tekrar basılırsa seçim kalkar (boş bırakma).
  void select(int option) {
    answers[index] = answers[index] == option ? -1 : option;
    notifyListeners();
  }

  void next() {
    if (index < total - 1) {
      index++;
      notifyListeners();
    }
  }

  void prev() {
    if (index > 0) {
      index--;
      notifyListeners();
    }
  }

  void finish() {
    record.answers = List<int>.from(answers);
    record.solved = true;
    finished = true;
    notifyListeners();
  }
}
