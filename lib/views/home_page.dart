import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/curriculum.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../viewmodels/tests_viewmodel.dart';
import '../widgets/common.dart';
import 'archive_page.dart';
import 'lessons_page.dart';
import 'level_page.dart';
import 'practice_page.dart';
import 'profile_page.dart';

class _MenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color bg;
  final Color fg;
  final Widget page;
  const _MenuItem(
      this.title, this.subtitle, this.icon, this.bg, this.fg, this.page);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _items = <_MenuItem>[
    _MenuItem('Seviye', 'Seviyeni belirle', Icons.trending_up,
        Color(0xFFDBEAFE), Color(0xFF3B82F6), LevelPage()),
    _MenuItem('Soru', 'Test üret ve çöz', Icons.quiz, Color(0xFFFFEDD5),
        Color(0xFFFB923C), PracticePage()),
    _MenuItem('Dersler', 'Dersler ve konular', Icons.menu_book,
        Color(0xFFD1FAE5), Color(0xFF10B981), LessonsPage()),
    _MenuItem('Arşiv', 'Geçmiş testlerin', Icons.inventory_2,
        Color(0xFFFEF3C7), Color(0xFFF59E0B), ArchivePage()),
    _MenuItem('Profil', 'Bilgilerin ve ilerleme', Icons.person,
        Color(0xFFFCE7F3), Color(0xFFEC4899), ProfilePage()),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _askFieldIfNeeded());
  }

  Future<void> _askFieldIfNeeded() async {
    if (!mounted) return;
    final profile = context.read<ProfileViewModel>();
    if (profile.field != null) return;
    final picked = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Hangi sınava hazırlanıyorsun?'),
        children: [
          for (final f in Curriculum.fields)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, f),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(f, style: const TextStyle(fontSize: 16)),
              ),
            ),
        ],
      ),
    );
    if (picked != null && mounted) {
      await profile.setField(picked);
    }
  }

  void _open(_MenuItem it) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SubPage(title: it.title, child: it.page),
    ));
  }

  Widget _tile(_MenuItem it) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _open(it),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: it.bg,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(it.icon, size: 30, color: it.fg),
                ),
                const SizedBox(height: 12),
                Text(it.title,
                    style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(it.subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textSoft, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileViewModel>();
    final tests = context.watch<TestsViewModel>();
    final field = profile.field;
    final progress = field == null ? 0.0 : tests.progress(field);
    final name = profile.name.trim();
    final initial = name.isEmpty ? null : name[0].toUpperCase();

    return GradientScaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isEmpty ? 'Merhaba 👋' : 'Merhaba, $name 👋',
                        style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 22,
                            fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      const Text('Bugün ne öğrenmek istersin?',
                          style: TextStyle(
                              color: AppColors.textSoft, fontSize: 14)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _open(_items[4]),
                  child: Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.accent,
                      boxShadow: AppColors.softShadow,
                    ),
                    child: initial == null
                        ? const Icon(Icons.person, color: Colors.white)
                        : Text(initial,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // İlerleme kartı
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppColors.softShadow,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Genel ilerleme',
                                style: TextStyle(
                                    color: AppColors.textSoft, fontSize: 13)),
                            Text(field ?? 'Alan seçilmedi',
                                style: const TextStyle(
                                    color: AppColors.textDark,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      Text('%${(progress * 100).round()}',
                          style: const TextStyle(
                              color: AppColors.peach,
                              fontSize: 24,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.accent,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppColors.softShadow,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Yapay Zeka ile\nSoru Paketi',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                height: 1.25,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 14),
                        FilledButton(
                          onPressed: () => _open(_items[1]),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFFEA580C),
                          ),
                          child: const Text('Hemen Başla'),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.auto_awesome,
                      size: 64, color: Colors.white70),
                ],
              ),
            ),
            const SizedBox(height: 22),

            const Text('Bölümler',
                style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.95,
              children: [for (final it in _items) _tile(it)],
            ),
            const SizedBox(height: 8),
            const YigitFooter(),
          ],
        ),
      ),
    );
  }
}