import 'package:flutter/material.dart';
import 'package:psi_circle_mobile/core/theme/psi_app_bar.dart';

class ChatsPlaceholderScreen extends StatelessWidget {
  const ChatsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PsiAppBar(title: Text('Chats')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Chat UI comes in Phase 5.\nConnect with people via Wave first.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ),
    );
  }
}
