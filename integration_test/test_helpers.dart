import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

Future<void> loginIfNeeded(WidgetTester tester) async {
  await tester.pumpAndSettle();

  // Авторизация
  final emailField = find.byType(TextFormField).first;
  final passwordField = find.byType(TextFormField).last;
  final loginButton = find.text('Войти');

  await tester.enterText(emailField, 'ad@ad.ad');
  await tester.enterText(passwordField, 'ad');
  await tester.tap(loginButton);
  await tester.pumpAndSettle();
}
