import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SettingsScreen integration test', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Вход в аккаунт
    await loginIfNeeded(tester);

    // Переход на вкладку "Настройки"
    final settingsTab = find.text('Настройки');
    expect(settingsTab, findsOneWidget);
    await tester.tap(settingsTab);
    await tester.pumpAndSettle();

    // Проверка email
    expect(find.byType(CircleAvatar), findsOneWidget);
    expect(find.byType(QrImageView), findsOneWidget);

    final emailText = find.byWidgetPredicate(
      (widget) =>
          widget is Text && widget.data != null && widget.data!.contains('@'),
    );
    expect(emailText, findsOneWidget);

    // Проверка имени, если оно есть
    final editNameButton = find.byIcon(Icons.edit);
    expect(editNameButton, findsOneWidget);

    // Переход на экран изменения имени
    await tester.tap(editNameButton);
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget); // поле ввода нового имени
    expect(find.text('Сохранить'), findsOneWidget);

    // Вернуться назад
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Нажать кнопку выхода
    final logoutButton = find.text('Выйти из аккаунта');
    expect(logoutButton, findsOneWidget);

    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    // Проверка, что мы вернулись на экран входа
    expect(find.byType(TextFormField).first, findsOneWidget);
    expect(find.byType(TextFormField).last, findsOneWidget);
    expect(find.text('Войти'), findsOneWidget);
  });
}
