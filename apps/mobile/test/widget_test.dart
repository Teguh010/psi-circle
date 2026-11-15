import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:psi_circle_mobile/main.dart';

void main() {
  testWidgets('App boots to the welcome screen in mock mode', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PsiCircleApp()));
    await tester.pumpAndSettle();

    expect(find.text('Psi Circle'), findsWidgets);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });
}
