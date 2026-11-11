import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:o_app/app/o_app.dart';
import 'package:o_app/features/auth/owner_gate.dart';

void main() {
  testWidgets('O opens through trusted owner-device gate', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: OApp()));

    expect(find.byType(OwnerGate), findsOneWidget);
    expect(find.text('Opening Next…'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 150));
    expect(
      find.text('Sign in once').evaluate().isNotEmpty ||
          find.text('Opening Next…').evaluate().isNotEmpty,
      isTrue,
    );
  });
}
