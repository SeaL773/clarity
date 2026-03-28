import 'package:clarity_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app renders main shell', (tester) async {
    await tester.pumpWidget(const ClarityApp());
    await tester.pump();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Recap'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
