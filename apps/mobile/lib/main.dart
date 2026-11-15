import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/session_controller.dart';

void main() {
  runApp(const ProviderScope(child: PsiCircleApp()));
}

class PsiCircleApp extends ConsumerStatefulWidget {
  const PsiCircleApp({super.key});

  @override
  ConsumerState<PsiCircleApp> createState() => _PsiCircleAppState();
}

class _PsiCircleAppState extends ConsumerState<PsiCircleApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionControllerProvider.notifier).bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Psi Circle',
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
