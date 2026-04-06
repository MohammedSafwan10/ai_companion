import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:ai_companion/main.dart';

void main() {
  setUpAll(() async {
    dotenv.testLoad(fileInput: 'GEMINI_API_KEY=test-key');
  });

  testWidgets('app boots inside ProviderScope and shows main navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Hub'), findsOneWidget);
    expect(find.byIcon(Icons.window_rounded), findsOneWidget);
    expect(find.byIcon(Icons.category_outlined), findsOneWidget);
    expect(find.byIcon(Icons.rocket_launch_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.category_outlined));
    await tester.pumpAndSettle();

    expect(find.text('AI Features'), findsOneWidget);
  });
}
