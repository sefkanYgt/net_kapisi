import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show ReadContext, WatchContext;

import '../core/curriculum.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../viewmodels/tests_viewmodel.dart';
import '../widgets/common.dart';
import 'login_page.dart';

/// 5. sayfa: Profil
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final TextEditingController _name;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: context.read<ProfileViewModel>().name);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final nav = Navigator.of(context);
    await context.read<AuthViewModel>().logout();
    if (!mounted) return;
    nav.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileViewModel>();
    final tests = context.watch<TestsViewModel>();
    final field = profile.field;

    final total = field == null ? 0 : Curriculum.totalTopics(field);
    final done = field == null ? 0 : tests.completedCount(field);
    final progress = field == null ? 0.0 : tests.progress(field);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _name,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'İsim Soyisim',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.save_outlined),
              onPressed: () {
                profile.setName(_name.text);
                FocusScope.of(context).unfocus();
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Kaydedildi')));
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Alan', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: [
            for (final f in Curriculum.fields)
              ButtonSegment(value: f, label: Text(f)),
          ],
          selected: {if (field != null) field},
          emptySelectionAllowed: true,
          onSelectionChanged: (s) {
            if (s.isNotEmpty) profile.setField(s.first);
          },
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Toplam ilerleme',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('%${(progress * 100).round()}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(field == null
                    ? 'Önce alan seç.'
                    : '$done / $total konu tamamlandı'),
                const SizedBox(height: 4),
                Text(
                  'Bir konuda en az bir test çözüldüyse konu tamamlanmış sayılır.',
                  style: TextStyle(
                      fontSize: 12, color: Theme.of(context).colorScheme.outline),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout),
          label: const Text('Çıkış yap'),
        ),
        const SizedBox(height: 8),
        const YigitFooter(),
      ],
    );
  }
}