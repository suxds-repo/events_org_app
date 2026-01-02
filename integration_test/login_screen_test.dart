import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('LoginScreen Integration Test — Ввод email и пароля, вход', (
    WidgetTester tester,
  ) async {
    // Запускаем приложение
    app.main();
    await tester.pumpAndSettle();

    // Находим поля ввода
    final emailField = find.byType(TextFormField).at(0);
    final passwordField = find.byType(TextFormField).at(1);

    // Вводим корректные данные существующего пользователя
    await tester.enterText(emailField, 'admin@admin.com');
    await tester.enterText(passwordField, 'admin');

    // Нажимаем на кнопку "Войти"
    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle(
      const Duration(seconds: 3),
    ); // ждём, пока загрузится следующий экран

    // Проверяем, что экран входа исчез (поиск текста "Добро пожаловать!" должен не найтись)
    expect(find.text('Добро пожаловать!'), findsNothing);
  });
}
