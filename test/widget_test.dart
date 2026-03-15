import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CropAIApp());
    expect(find.text('CropAI — Smart Farming'), findsOneWidget);
  });
}