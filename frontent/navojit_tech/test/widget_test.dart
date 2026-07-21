import 'package:flutter_test/flutter_test.dart';
import 'package:navojit_tech/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NaovjitTechApp());
    await tester.pumpAndSettle();
    // Verify the app renders without crashing
    expect(find.byType(NaovjitTechApp), findsOneWidget);
  });
}
