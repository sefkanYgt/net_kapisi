import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/common.dart';
import 'home_page.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      final loggedIn = context.read<AuthViewModel>().isLoggedIn;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => loggedIn ? const HomePage() : const LoginPage(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            const LogoWidget(size: 130),
            const SizedBox(height: 22),
            const Text('Soru Üretim Merkezi',
                style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 24,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Yapay zeka ile akıllı sorular',
                style: TextStyle(color: AppColors.textSoft)),
            const Spacer(),
            const YigitFooter(),
          ],
        ),
      ),
    );
  }
}