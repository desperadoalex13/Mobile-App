import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/shared/widgets/error_view.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('ErrorView', () {
    testWidgets('displays the error message', (tester) async {
      await tester.pumpWidget(
        _wrap(const ErrorView(message: 'Something went wrong')),
      );
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('shows error icon', (tester) async {
      await tester.pumpWidget(
        _wrap(const ErrorView(message: 'Error')),
      );
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows retry button when callback provided', (tester) async {
      await tester.pumpWidget(
        _wrap(ErrorView(message: 'Error', onRetry: () {})),
      );
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('hides retry button when no callback', (tester) async {
      await tester.pumpWidget(
        _wrap(const ErrorView(message: 'Error')),
      );
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('calls onRetry when retry button tapped', (tester) async {
      var called = false;
      await tester.pumpWidget(
        _wrap(ErrorView(message: 'Error', onRetry: () => called = true)),
      );
      await tester.tap(find.text('Retry'));
      expect(called, isTrue);
    });
  });
}
