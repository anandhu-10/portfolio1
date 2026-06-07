import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Portfolio loads and builds without exceptions', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    
    // Set a desktop screen size to prevent grid cell overflow issues in the test
    await tester.binding.setSurfaceSize(const Size(1920, 1080));
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    
    // Pump frames with duration to let async initialization complete
    // We avoid pumpAndSettle because of infinite animations in the Hero section.
    await tester.pump(const Duration(seconds: 1));
    
    // Check for startup exceptions
    final dynamic exception = tester.takeException();
    if (exception != null) {
      print('EXCEPTION DURING STARTUP: $exception');
      throw exception;
    }
    
    // Check if MyApp is built and visible
    expect(find.byType(MyApp), findsOneWidget);
    
    // Verify that the home section elements are present
    expect(find.text('Contact Me'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);

    // Clean up to dispose active timers/animations
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
