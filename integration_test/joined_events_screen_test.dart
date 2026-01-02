import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/main.dart' as app;
import 'package:my_app/widgets/event_card.dart';
import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('JoinedEventsScreen test: загрузка, поиск, переход', (
    WidgetTester tester,
  ) async {
    app.main();
    await loginIfNeeded(tester);
    // Переключение на вкладку "Мои"
    final myTab = find.byIcon(Icons.check_circle);
    expect(myTab, findsOneWidget);
    await tester.tap(myTab);
    await tester.pumpAndSettle();

    // Проверка поля поиска
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);

    // Ввод текста для фильтрации
    await tester.enterText(
      searchField,
      'a',
    ); // Подставь часть названия твоего мероприятия
    await tester.pumpAndSettle();

    // Проверка наличия результатов
    final eventCard = find.byType(EventCard); // Или EventCard, если он доступен
    expect(
      eventCard,
      findsWidgets,
    ); // Проверка, что есть хотя бы один результат

    // Переход на экран деталей мероприятия
    await tester.tap(eventCard.first);
    await tester.pumpAndSettle();

    // Проверка деталей мероприятия (например, заголовок)
    final detailsTitle = find.textContaining(
      'Описание',
    ); // Подставь название мероприятия
    expect(detailsTitle, findsWidgets);
  });
}
