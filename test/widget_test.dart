import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:streakly/theme/app_theme.dart';

void main() {
  testWidgets('Streakly design theme loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: Text('Streakly')),
      ),
    );

    expect(find.text('Streakly'), findsOneWidget);
  });
}
