import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/config.dart';
import '../core/utils.dart';

/// Logo. Kendi logonuzu eklemek için assets/logo.png koyup
/// Icon yerine Image.asset('assets/logo.png') kullanın.
class LogoWidget extends StatelessWidget {
  final double size;
  const LogoWidget({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3),
        gradient: AppColors.accent,
        boxShadow: AppColors.softShadow,
      ),
      child: Icon(Icons.psychology_alt, size: size * 0.55, color: Colors.white),
    );
  }
}

class YigitFooter extends StatelessWidget {
  const YigitFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Text(
        AppConfig.footerText,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textSoft,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class LevelBadge extends StatelessWidget {
  final String level;
  const LevelBadge(this.level, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = Levels.color(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        Levels.label(level),
        style: TextStyle(
            color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

class NeedFieldView extends StatelessWidget {
  const NeedFieldView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Önce Profil sayfasından alanını (YKS / KPSS) seçmelisin.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const StatChip(this.label, this.value, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text('$value',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }
}

/// Ana sayfadaki kartlara basınca açılan sayfaların ortak çerçevesi.
class SubPage extends StatelessWidget {
  final String title;
  final Widget child;
  const SubPage({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(title: Text(title)),
      body: child,
    );
  }
}