import 'package:flutter_test/flutter_test.dart';
import 'package:nahriva/main.dart';

void main() {
  testWidgets('App launches without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const NahrivaApp());
    expect(find.byType(NahrivaApp), findsOneWidget);
  });
}
