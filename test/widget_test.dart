import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greviance/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // MyApp now requires an initialHome widget.
    await tester.pumpWidget(const MyApp(
      initialHome: Scaffold(body: Text('Login')),
    ));

    // Basic check to see if the app renders.
    expect(find.text('Login'), findsOneWidget);
  });
}
