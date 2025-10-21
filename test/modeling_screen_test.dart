import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/modeling/view/modeling_screen.dart';

void main() {
  testWidgets('ModelingScreen displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ModelingScreen(),
      ),
    );

    // Verify that the screen builds without throwing exceptions
    expect(find.byType(ModelingScreen), findsOneWidget);
  });
}