// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_custom_component/main.dart';

void main() {
  testWidgets('Component showcase smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for one frame to render
    await tester.pump();

    // Verify that the app title is displayed
    expect(find.text('Beautiful Custom Components'), findsOneWidget);

    // Verify that at least some component sections are displayed
    expect(find.text('1. Animated Info Card'), findsOneWidget);
    expect(find.text('2. Glassmorphic Buttons'), findsOneWidget);
    expect(find.text('3. Gradient Progress Cards'), findsOneWidget);

    // Verify that buttons exist
    expect(find.text('Primary'), findsOneWidget);
    expect(find.text('Secondary'), findsOneWidget);
  });
}
