import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils.dart';
import '../models/test_record.dart';
import '../viewmodels/test_session_viewmodel.dart';
import '../widgets/common.dart';
import '../core/app_theme.dart';
/// Test çözme + sonuç ekranı. Bitince [onFinished] çağrılır.
class TestPage extends StatelessWidget {
  final TestRecord record;
  final bool showExplanations;
  final bool isLevelTest;
  final void Function(TestRecord) onFinished;

  const TestPage({
    super.key,
    required this.record,
    required this.showExplanations,
    required this.isLevelTest,
    required this.onFinished,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TestSessionViewModel(record),
      child: _TestView(
        showExplanations: showExplanations,
        isLevelTest: isLevelTest,
        onFinished: onFinished,
      ),
    );
  }
}

class _TestView extends StatelessWidget {
  final bool showExplanations;
  final bool isLevelTest;
  final void Function(TestRecord) onFinished;
  const _TestView({
    required this.showExplanations,
    required this.isLevelTest,
    required this.onFinished,
  });

  static const letters = ['A', 'B', 'C', 'D', 'E', 'F'];

  Future<bool> _confirm(BuildContext context, String title, String msg) async {
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Vazgeç')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Tamam')),
        ],
      ),
    );
    return r ?? false;
  }

  Future<void> _finish(BuildContext context, TestSessionViewModel s) async {
    final blank = s.blankCount;
    final ok = await _confirm(
      context,
      'Testi bitir',
      blank == 0
          ? 'Testi bitirmek istiyor musun?'
          : '$blank soru boş. Yine de bitirmek istiyor musun?',
    );
    if (!ok) return;
    s.finish();
    onFinished(s.record);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<TestSessionViewModel>();
    final r = s.record;

    return PopScope(
      canPop: s.finished,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await _confirm(context, 'Testten çık',
            'Çıkarsan bu testteki cevapların kaydedilmez.');
        if (leave && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.finished ? 'Sonuç' : r.topic),
          automaticallyImplyLeading: !s.finished,
        ),
        body: s.finished ? _result(context, s) : _question(context, s),
      ),
    );
  }

  Widget _question(BuildContext context, TestSessionViewModel s) {
    final q = s.record.questions[s.index];
    final c = Theme.of(context).colorScheme;
    final last = s.index == s.total - 1;

    return Column(
      children: [
        LinearProgressIndicator(value: (s.index + 1) / s.total),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Soru ${s.index + 1} / ${s.total}',
                  style: TextStyle(color: c.outline)),
              const SizedBox(height: 8),
              Text(q.text, style: const TextStyle(fontSize: 17, height: 1.4)),
              const SizedBox(height: 16),
              for (var i = 0; i < q.options.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => s.select(i),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: s.answers[s.index] == i
                              ? c.primary
                              : c.outlineVariant,
                          width: s.answers[s.index] == i ? 2 : 1,
                        ),
                        color: s.answers[s.index] == i
                            ? c.primaryContainer
                            : null,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            child: Text(letters[i],
                                style: const TextStyle(fontSize: 13)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(q.options[i])),
                        ],
                      ),
                    ),
                  ),
                ),
              Text('Cevabı kaldırmak (boş bırakmak) için seçili şıkka tekrar dokun.',
                  style: TextStyle(color: c.outline, fontSize: 12)),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: s.index == 0 ? null : s.prev,
                  child: const Text('Önceki'),
                ),
                const Spacer(),
                if (!last)
                  FilledButton(onPressed: s.next, child: const Text('Sonraki'))
                else
                  FilledButton(
                    onPressed: () => _finish(context, s),
                    child: const Text('Bitir'),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _result(BuildContext context, TestSessionViewModel s) {
    final r = s.record;
    final c = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            StatChip('Doğru', r.correct, Colors.green),
            const SizedBox(width: 8),
            StatChip('Yanlış', r.wrong, Colors.red),
            const SizedBox(width: 8),
            StatChip('Boş', r.blank, Colors.grey),
          ],
        ),
        if (isLevelTest) ...[
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('Belirlenen seviye: ',
                      style: TextStyle(fontSize: 16)),
                  LevelBadge(Levels.fromCorrect(r.correct)),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        for (var i = 0; i < r.questions.length; i++) _reviewCard(context, r, i, c),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Kapat'),
          ),
        ),
      ],
    );
  }

  Widget _reviewCard(BuildContext context, TestRecord r, int i, ColorScheme c) {
    final q = r.questions[i];
    final a = r.answers[i];
    final isBlank = a < 0;
    final isCorrect = a == q.correctIndex;
    final color = isBlank ? Colors.grey : (isCorrect ? Colors.green : Colors.red);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isBlank
                      ? Icons.remove_circle_outline
                      : (isCorrect ? Icons.check_circle : Icons.cancel),
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text('Soru ${i + 1}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 6),
            Text(q.text),
            const SizedBox(height: 8),
            Text(
              'Senin cevabın: ${isBlank ? 'Boş' : '${letters[a]}) ${q.options[a]}'}',
              style: TextStyle(color: color),
            ),
            Text(
              'Doğru cevap: ${letters[q.correctIndex]}) ${q.options[q.correctIndex]}',
              style: const TextStyle(
                  color: Colors.green, fontWeight: FontWeight.w600),
            ),
            if (showExplanations && q.explanation.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: c.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Açıklama: ${q.explanation}'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
