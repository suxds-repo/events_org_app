import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/main.dart' as app;

import 'test_helpers.dart'; // Импорт вашей точки входа

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('HomeScreen Integration Test: вход, вкладки, выход', (
    tester,
  ) async {
    app.main(); // Запуск приложения
    await tester.pumpAndSettle();

    await loginIfNeeded(tester);

    // --- ПОСЛЕ ВХОДА ---
    expect(
      find.byIcon(Icons.event),
      findsOneWidget,
    ); // Проверка иконки первой вкладки

    // --- ПЕРЕКЛЮЧЕНИЕ НА "МОИ" ---
    await tester.tap(find.byIcon(Icons.check_circle));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Мои'),
      findsWidgets,
    ); // Заголовок или элемент на JoinedEventsScreen

    // --- ПЕРЕКЛЮЧЕНИЕ НА "НАСТРОЙКИ" ---
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Настройки'),
      findsWidgets,
    ); // Убедимся, что мы на экране настроек

    // --- ВЫХОД ИЗ АККАУНТА ---
    await tester.tap(
      find.text('Выйти из аккаунта'),
    ); // Кнопка с текстом "Выйти"
    await tester.pumpAndSettle();

    // --- ОБРАТНО НА ЭКРАН ВХОДА ---
    expect(
      find.textContaining('Вход'),
      findsWidgets,
    ); // Заголовок на экране входа
  });
}
