import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/main.dart' as app;
import 'package:my_app/widgets/event_card.dart';
import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SearchScreen integration test', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Войти в аккаунт
    await loginIfNeeded(tester);

    // Переход на вкладку "Поиск"
    final searchTab = find.byType(TextField);
    expect(searchTab, findsOneWidget);
    await tester.tap(searchTab);
    await tester.pumpAndSettle();

    // Ожидание загрузки мероприятий
    expect(find.byType(EventCard), findsWidgets); // мероприятия найдены

    // Ввод текста в поле поиска
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);
    await tester.enterText(searchField, 'a');
    await tester.pumpAndSettle();

    // Проверка фильтрации
    final filteredList = find.byType(EventCard);
    expect(filteredList, findsWidgets); // хотя бы один элемент остался

    // Проверка, что названия содержат "тест"
    for (final widget in filteredList.evaluate()) {
      final tile = widget.widget as EventCard;
      final title = tile.event['title'] as String;
      expect(title.toLowerCase(), contains('a'));
    }
  });
}
