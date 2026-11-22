import 'package:flutter/foundation.dart';

class LessonsViewModel extends ChangeNotifier {
  String? lesson;

  void selectLesson(String? v) {
    lesson = v;
    notifyListeners();
  }
}
