import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/curriculum.dart';
import '../models/test_record.dart';
import '../services/pdf_service.dart';
import '../viewmodels/practice_viewmodel.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../viewmodels/tests_viewmodel.dart';
import '../widgets/common.dart';
import 'test_page.dart';

/// 2. sayfa: Soru (20 soru üret, test çöz veya PDF indir)
class PracticePage extends StatelessWidget {
  const PracticePage({super.key});

  Future<TestRecord?> _generate(BuildContext context, String field) async {
    final vm = context.read<PracticeViewModel>();
    final tests = context.read<TestsViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    final r = await vm.generate(field, tests);
    if (r == null) {
      messenger.showSnackBar(SnackBar(content: Text(vm.error ?? 'Hata oluştu')));
    }
    return r;
  }

  Future<void> _solve(BuildContext context, String field) async {
    final vm = context.read<PracticeViewModel>();
    final tests = context.read<TestsViewModel>();
    final r = await _generate(context, field);
    if (r == null || !context.mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TestPage(
        record: r,
        showExplanations: vm.explanations,
        isLevelTest: false,
        onFinished: tests.updateRecord,
      ),
    ));
  }

  Future<void> _pdf(BuildContext context, String field) async {
    final vm = context.read<PracticeViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    final r = await _generate(context, field);
    if (r == null) return;
    try {
      await PdfService.share(r, explanations: vm.explanations);
    } catch (e) {
      messenger.showSnackBar(
          SnackBar(content: Text('PDF oluşturulamadı: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final field = context.watch<ProfileViewModel>().field;
    if (field == null) return const NeedFieldView();
    final vm = context.watch<PracticeViewModel>();
    final tests = context.watch<TestsViewModel>();

    final lessons = Curriculum.lessons(field);
    final lesson = lessons.contains(vm.lesson) ? vm.lesson : null;
    final topics = lesson == null ? <String>[] : Curriculum.topics(field, lesson);
    final topic = topics.contains(vm.topic) ? vm.topic : null;

    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: DropdownButtonFormField<String>(
                value: lesson,
                decoration: const InputDecoration(
                    labelText: 'Ders', border: OutlineInputBorder()),
                items: [
                  for (final l in lessons)
                    DropdownMenuItem(value: l, child: Text(l))
                ],
                onChanged: vm.loading ? null : vm.selectLesson,
              ),
            ),
            SwitchListTile(
              title: const Text('Cevap açıklaması'),
              subtitle: const Text('Testte ve PDF\'te açıklamalar gösterilsin'),
              value: vm.explanations,
              onChanged: vm.setExplanations,
            ),
            Expanded(
              child: lesson == null
                  ? const Center(child: Text('Bir ders seç'))
                  : ListView(
                children: [
                  for (final t in topics) _topicTile(context, tests, vm, field, lesson, t),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: (topic == null || vm.loading)
                            ? null
                            : () => _solve(context, field),
                        icon: const Icon(Icons.edit_note),
                        label: const Text('Test çöz'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: (topic == null || vm.loading)
                            ? null
                            : () => _pdf(context, field),
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        label: const Text('PDF indir'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (vm.loading)
          Positioned.fill(
            child: Container(
              color: Colors.black38,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('20 soru üretiliyor...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _topicTile(BuildContext context, TestsViewModel tests,
      PracticeViewModel vm, String field, String lesson, String t) {
    final level = tests.levelOf(field, lesson, t);
    final enabled = level != null;
    final selected = vm.topic == t;
    return ListTile(
      enabled: enabled,
      selected: selected,
      selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
      title: Text(t),
      subtitle: enabled ? null : const Text('Önce Seviye sayfasında seviyeni belirle'),
      trailing: enabled ? LevelBadge(level) : null,
      onTap: enabled ? () => vm.selectTopic(t) : null,
    );
  }
}
