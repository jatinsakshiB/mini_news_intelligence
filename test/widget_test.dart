import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_news_intelligence/core/widgets/error_view.dart';
import 'package:mini_news_intelligence/features/news/presentation/widgets/category_bar.dart';

void main() {
  testWidgets('ErrorView renders message and triggers retry', (tester) async {
    bool retried = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorView(
            message: 'Unable to connect to server',
            onRetry: () {
              retried = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Unable to connect to server'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);

    await tester.tap(find.text('Try Again'));
    await tester.pump();

    expect(retried, isTrue);
  });

  testWidgets('CategoryBar displays categories and responds to taps', (
    tester,
  ) async {
    String selected = 'General';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CategoryBar(
            selectedCategory: selected,
            onCategorySelected: (cat) {
              selected = cat;
            },
          ),
        ),
      ),
    );

    expect(find.text('General'), findsOneWidget);
    expect(find.text('Technology'), findsOneWidget);

    await tester.tap(find.text('Technology'));
    await tester.pump();

    expect(selected, equals('Technology'));
  });
}
