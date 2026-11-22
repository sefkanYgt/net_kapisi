import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/curriculum.dart';
import '../viewmodels/level_viewmodel.dart';
import '../viewmodels/practice_viewmodel.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../viewmodels/tests_viewmodel.dart';
import '../widgets/common.dart';
import 'practice_page.dart';
import 'test_page.dart';

/// 1. sayfa: Seviye belirleme
class LevelPage extends StatelessWidget {
  const LevelPage({super.key});

  Future<void> _start(BuildContext context, String field) async {
    final vm = context.read<LevelViewModel>();
    final tests = context.read<TestsViewModel>();
    final messenger = ScaffoldMessenger.of(context);

    final record = await vm.generate(field);
    if (record == null) {
      messenger.showSnackBar(SnackBar(content: Text(vm.error ?? 'Hata oluştu')));
      return;
    }
    if (!context.mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TestPage(
        record: record,
        showExplanations: true,
        isLevelTest: true,
        onFinished: (r) => vm.complete(r, tests),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final field = context.watch<ProfileViewModel>().field;
    if (field == null) return const NeedFieldView();
    final vm = context.watch<LevelViewModel>();

    final lessons = Curriculum.lessons(field);
    final lesson = lessons.contains(vm.lesson) ? vm.lesson : null;
    final topics = lesson == null ? <String>[] : Curriculum.topics(field, lesson);
    final topic = topics.contains(vm.topic) ? vm.topic : null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('$field seviye belirleme',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        const Text(
            'Ders ve konu seç. 5 soru gelecek (1 kolay, 2 orta, 2 zor). '
                'Doğru sayına göre seviyen belirlenir.'),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: lesson,
          decoration: const InputDecoration(
              labelText: 'Ders', border: OutlineInputBorder()),
          items: [
            for (final l in lessons) DropdownMenuItem(value: l, child: Text(l))
          ],
          onChanged: vm.loading ? null : vm.selectLesson,
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          key: ValueKey('topic-$lesson'),
          value: topic,
          isExpanded: true,
          decoration: const InputDecoration(
              labelText: 'Konu', border: OutlineInputBorder()),
          items: [
            for (final t in topics) DropdownMenuItem(value: t, child: Text(t))
          ],
          onChanged: (vm.loading || lesson == null) ? null : vm.selectTopic,
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: (topic == null || vm.loading)
              ? null
              : () => _start(context, field),
          icon: vm.loading
              ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.flag_outlined),
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(vm.loading ? 'Sorular hazırlanıyor...' : 'Belirle'),
          ),
        ),
        if (vm.resultLevel != null && lesson != null && topic != null) ...[
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Seviyen: ', style: TextStyle(fontSize: 18)),
                      LevelBadge(vm.resultLevel!),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('${vm.resultCorrect}/5 doğru'),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Soru üret'),
                      onPressed: () {
                        context.read<PracticeViewModel>().select(lesson, topic);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const SubPage(
                                title: 'Soru', child: PracticePage()),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}