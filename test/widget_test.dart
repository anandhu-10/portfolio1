import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/main.dart';

void main() {
  testWidgets('Portfolio loads and builds without exceptions', (WidgetTester tester) async {
    // Set a desktop screen size to prevent grid cell overflow issues in the test
    await tester.binding.setSurfaceSize(const Size(1920, 1080));
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    
    // Pump frames for initial animations (pump 10 frames)
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    
    // Check if MyApp is built and visible
    expect(find.byType(MyApp), findsOneWidget);
    
    // Verify that the home section elements are present
    expect(find.text('Contact Me'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
  });
}
