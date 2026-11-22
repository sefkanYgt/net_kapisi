class Question {
  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String difficulty;

  const Question({
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.difficulty,
  });

  factory Question.fromJson(Map<String, dynamic> j) => Question(
    text: (j['text'] ?? '').toString(),
    options: (j['options'] as List).map((e) => e.toString()).toList(),
    correctIndex: (j['correctIndex'] as num).toInt(),
    explanation: (j['explanation'] ?? '').toString(),
    difficulty: (j['difficulty'] ?? '').toString(),
  );

  Map<String, dynamic> toJson() => {
    'text': text,
    'options': options,
    'correctIndex': correctIndex,
    'explanation': explanation,
    'difficulty': difficulty,
  };
}
