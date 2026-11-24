import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nongki/features/welcome/welcome_screen.dart';

void main() {
  testWidgets('WelcomeScreen renders Mulai and Masuk buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: WelcomeScreen(),
        ),
      ),
    );

    // Pump past initial animation delay
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Mulai'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.textContaining('Temukan tempat'), findsOneWidget);
  });
}
