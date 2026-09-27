import 'package:flutter_test/flutter_test.dart';
import 'package:ofix_app/main.dart';

void main() {
  testWidgets('OFIX inicia correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(const OfixApp());

    expect(find.text('OFIX'), findsOneWidget);
  });
}