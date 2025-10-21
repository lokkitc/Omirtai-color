// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/app/app.dart';
import 'package:app/core/services/persistence_service.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Initialize the persistence service
    await PersistenceService().init();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app loads without errors.
    expect(tester.widgetList(find.byType(MaterialApp)).length, greaterThan(0));
  });
}