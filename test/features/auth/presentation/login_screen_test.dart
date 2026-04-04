import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/auth/presentation/auth_controller.dart';
import 'package:mobile_app/features/auth/presentation/login_screen.dart';
import 'package:mobile_app/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Stub controllers — extend AuthController so overrideWith type-checks pass.
// All Firebase calls are overridden to be no-ops.
// ---------------------------------------------------------------------------

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
  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    // Never resolves — simulates an in-flight request.
    await Completer<void>().future;
  }

  @override
  Future<void> register(String email, String password) async {}

  @override
  Future<void> signOut() async {}
}

Widget _buildSubject({bool loading = false}) {
  return ProviderScope(
    overrides: [
      authControllerProvider.overrideWith(
        loading ? _LoadingAuthController.new : _StubAuthController.new,
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const LoginScreen(),
    ),
  );
}

void main() {
  group('LoginScreen — form validation', () {
    testWidgets('renders email and password fields', (tester) async {
      await tester.pumpWidget(_buildSubject());
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('shows error when email is empty', (tester) async {
      await tester.pumpWidget(_buildSubject());

      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Enter your email'), findsOneWidget);
    });

    testWidgets('shows error when email has no @', (tester) async {
      await tester.pumpWidget(_buildSubject());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'notanemail',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('shows error when password is empty', (tester) async {
      await tester.pumpWidget(_buildSubject());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'a@b.com',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Enter your password'), findsOneWidget);
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
        '123',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
    });
  });

  group('LoginScreen — loading state', () {
    testWidgets('button is disabled while auth is loading', (tester) async {
      await tester.pumpWidget(_buildSubject(loading: true));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'a@b.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });
  });

  group('LoginScreen — navigation link', () {
    testWidgets('Register link is present', (tester) async {
      await tester.pumpWidget(_buildSubject());
      expect(find.text('Register'), findsOneWidget);
    });
  });
}
