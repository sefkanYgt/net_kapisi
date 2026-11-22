import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/curriculum.dart';
import '../viewmodels/lessons_viewmodel.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../viewmodels/tests_viewmodel.dart';
import '../widgets/common.dart';

/// 3. sayfa: Ders -> konular -> konu detayı (seviye, doğru/yanlış/boş)
class LessonsPage extends StatelessWidget {
  const LessonsPage({super.key});

  void _showDetail(BuildContext context, String field, String lesson, String topic) {
    final tests = context.read<TestsViewModel>();
    final level = tests.levelOf(field, lesson, topic);
    final st = tests.statsOf(field, lesson, topic);

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(topic,
                style: Theme.of(ctx)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Text(lesson, style: TextStyle(color: Theme.of(ctx).colorScheme.outline)),
            const SizedBox(height: 14),
            Row(
              children: [
                const Text('Seviye: ', style: TextStyle(fontSize: 16)),
                LevelBadge(level ?? ''),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                StatChip('Doğru', st.correct, Colors.green),
                const SizedBox(width: 8),
                StatChip('Yanlış', st.wrong, Colors.red),
                const SizedBox(width: 8),
                StatChip('Boş', st.blank, Colors.grey),
              ],
            ),
            const SizedBox(height: 10),
            Text('Çözülen test sayısı: ${st.tests}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final field = context.watch<ProfileViewModel>().field;
    if (field == null) return const NeedFieldView();
    final vm = context.watch<LessonsViewModel>();
    final tests = context.watch<TestsViewModel>();

    final lessons = Curriculum.lessons(field);
    final lesson = lessons.contains(vm.lesson) ? vm.lesson : null;
    final topics = lesson == null ? <String>[] : Curriculum.topics(field, lesson);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: DropdownButtonFormField<String>(
            value: lesson,
            decoration: const InputDecoration(
                labelText: 'Ders', border: OutlineInputBorder()),
            items: [
              for (final l in lessons) DropdownMenuItem(value: l, child: Text(l))
            ],
            onChanged: vm.selectLesson,
          ),
        ),
        Expanded(
          child: lesson == null
              ? const Center(child: Text('Bir ders seç'))
              : ListView(
            children: [
              for (final t in topics)
                ListTile(
                  title: Text(t),
                  leading: Icon(
                    tests.isCompleted(field, lesson, t)
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: tests.isCompleted(field, lesson, t)
                        ? Colors.green
                        : null,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showDetail(context, field, lesson, t),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
