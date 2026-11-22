import 'question.dart';

class TestRecord {
  final String id;
  final DateTime createdAt;
  final String field;
  final String lesson;
  final String topic;

  /// 'level' (seviye belirleme) veya 'practice' (soru üretimi)
  final String kind;

  /// Belirlenen / kullanılan seviye: kolay, orta, zor
  String level;
  final List<Question> questions;

  /// Her soru için seçilen şık; -1 = boş
  List<int> answers;
  bool solved;

  TestRecord({
    required this.id,
    required this.createdAt,
    required this.field,
    required this.lesson,
    required this.topic,
    required this.kind,
    required this.level,
    required this.questions,
    required this.answers,
    required this.solved,
  });

  factory TestRecord.create({
    required String field,
    required String lesson,
    required String topic,
    required String kind,
    required String level,
    required List<Question> questions,
  }) =>
      TestRecord(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        field: field,
        lesson: lesson,
        topic: topic,
        kind: kind,
        level: level,
        questions: questions,
        answers: List<int>.filled(questions.length, -1),
        solved: false,
      );

  int get blank => solved ? answers.where((a) => a < 0).length : 0;

  int get correct {
    if (!solved) return 0;
    var c = 0;
    for (var i = 0; i < questions.length && i < answers.length; i++) {
      if (answers[i] == questions[i].correctIndex) c++;
    }
    return c;
  }

  int get wrong => solved ? questions.length - correct - blank : 0;

  factory TestRecord.fromJson(Map<String, dynamic> j) => TestRecord(
    id: j['id'] as String,
    createdAt: DateTime.parse(j['createdAt'] as String),
    field: j['field'] as String,
    lesson: j['lesson'] as String,
    topic: j['topic'] as String,
    kind: j['kind'] as String,
    level: (j['level'] ?? '') as String,
    questions: (j['questions'] as List)
        .map((e) => Question.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    answers: (j['answers'] as List).map((e) => (e as num).toInt()).toList(),
    solved: j['solved'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'field': field,
    'lesson': lesson,
    'topic': topic,
    'kind': kind,
    'level': level,
    'questions': questions.map((q) => q.toJson()).toList(),
    'answers': answers,
    'solved': solved,
  };
}
