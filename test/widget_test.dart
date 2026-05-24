import 'package:flutter_test/flutter_test.dart';
import 'package:streakly/main.dart';

void main() {
  testWidgets('Streakly app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Streakly'), findsWidgets);
  });
}