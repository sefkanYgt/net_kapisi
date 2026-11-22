import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils.dart';
import '../models/test_record.dart';
import '../services/pdf_service.dart';
import '../viewmodels/tests_viewmodel.dart';
import '../widgets/common.dart';
import 'test_page.dart';

/// 4. sayfa: Arşiv (üretilen / çözülen tüm testler)
class ArchivePage extends StatelessWidget {
  const ArchivePage({super.key});

  Future<void> _download(BuildContext context, TestRecord r) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await PdfService.share(r, explanations: true);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('PDF oluşturulamadı: $e')));
    }
  }

  void _openUnsolved(BuildContext context, TestRecord r) {
    final tests = context.read<TestsViewModel>();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TestPage(
        record: r,
        showExplanations: true,
        isLevelTest: false,
        onFinished: tests.updateRecord,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final records = context.watch<TestsViewModel>().records;
    if (records.isEmpty) {
      return const Center(child: Text('Henüz test yok.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: records.length,
      itemBuilder: (context, i) {
        final r = records[i];
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: r.solved ? null : () => _openUnsolved(context, r),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${r.lesson} • ${r.topic}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 2),
                        Text(
                          '${r.kind == 'level' ? 'Seviye testi' : 'Soru testi'}'
                              ' • ${r.field} • ${fmtDate(r.createdAt)}',
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.outline),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            LevelBadge(r.level),
                            const SizedBox(width: 10),
                            if (r.solved)
                              Text('Doğru ${r.correct}  Yanlış ${r.wrong}  Boş ${r.blank}')
                            else
                              const Text('Çözülmedi (çözmek için dokun)'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'PDF indir',
                    icon: const Icon(Icons.download),
                    onPressed: () => _download(context, r),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
