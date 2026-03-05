import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/auth/presentation/auth_controller.dart';
import 'package:mobile_app/features/auth/presentation/register_screen.dart';

class _StubAuthController extends AuthController {
  @override
  Future<void> signIn(String email, String password) async {}

  @override
  Future<void> register(String email, String password) async {}

  @override
  Future<void> signOut() async {}
}

class _LoadingAuthController extends AuthController {
  @override
  Future<void> signIn(String email, String password) async {}

  @override
  Future<void> register(String email, String password) async {
    state = const AsyncLoading();
    await Completer<void>().future;
  }

  @override
  Future<void> signOut() async {}
}

// Register screen has both a title "Create Account" and a button "Create Account".
// Use this finder to uniquely target the submit button.
final _submitButton = find.widgetWithText(FilledButton, 'Create Account');

Widget _buildSubject({bool loading = false}) {
  return ProviderScope(
    overrides: [
      authControllerProvider.overrideWith(
        loading ? _LoadingAuthController.new : _StubAuthController.new,
      ),
    ],
    child: const MaterialApp(home: RegisterScreen()),
  );
}

void main() {
  group('RegisterScreen — form validation', () {
    testWidgets('renders three form fields', (tester) async {
      await tester.pumpWidget(_buildSubject());
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('shows error when email is empty', (tester) async {
      await tester.pumpWidget(_buildSubject());

      await tester.tap(_submitButton);
      await tester.pump();

      expect(find.text('Enter your email'), findsOneWidget);
    });

    testWidgets('shows error when email has no @', (tester) async {
      await tester.pumpWidget(_buildSubject());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'notvalid',
      );
      await tester.tap(_submitButton);
      await tester.pump();

      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('shows error when password is shorter than 6 chars',
        (tester) async {
      await tester.pumpWidget(_buildSubject());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'a@b.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        '12',
      );
      await tester.tap(_submitButton);
      await tester.pump();

      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
    });

    testWidgets('shows error when passwords do not match', (tester) async {
      await tester.pumpWidget(_buildSubject());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'a@b.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'pass123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'different',
      );
      await tester.tap(_submitButton);
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });

  group('RegisterScreen — loading state', () {
    testWidgets('button is disabled while auth is loading', (tester) async {
      await tester.pumpWidget(_buildSubject(loading: true));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'a@b.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'pass123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'pass123',
      );
      await tester.tap(_submitButton);
      await tester.pump();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });
  });

  group('RegisterScreen — navigation link', () {
    testWidgets('Sign In link is present', (tester) async {
      await tester.pumpWidget(_buildSubject());
      expect(find.text('Sign In'), findsOneWidget);
    });
  });
}
