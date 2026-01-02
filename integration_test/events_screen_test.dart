import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/main.dart' as app;
import 'package:my_app/widgets/event_card.dart';
import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('EventsScreen отображает список, ищет и переходит к деталям', (
    tester,
  ) async {
    // Запускаем приложение
    app.main();
    await tester.pumpAndSettle();
    await loginIfNeeded(tester);
    // Ждём, пока не появится нижняя навигация
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Нажимаем на первую вкладку (EventsScreen)
    await tester.tap(find.byIcon(Icons.event));
    await tester.pumpAndSettle();

    // Проверяем, что мы на экране мероприятий
    expect(find.text('Поиск мероприятий...'), findsOneWidget);

    // Ожидаем отображения хотя бы одного EventCard
    await tester.pumpAndSettle(const Duration(seconds: 2));
    final eventCardFinder = find.byType(Card);

    if (eventCardFinder.evaluate().isNotEmpty) {
      // Получаем текст заголовка первого мероприятия
      final firstEventTitleFinder = find.descendant(
        of: find.byType(EventCard).first,
        matching: find.byType(Text),
      );

      expect(firstEventTitleFinder, findsWidgets);

      final titleWidget = tester.widget<Text>(firstEventTitleFinder.first);
      expect(titleWidget.data?.toLowerCase(), contains('j'));
      final eventTitle = titleWidget.data ?? '';

      // Выполняем поиск по заголовку первого мероприятия
      await tester.enterText(
        find.byType(TextField),
        eventTitle.substring(0, (eventTitle.length / 2).ceil()), // часть текста
      );
      await tester.pumpAndSettle();

      // Проверяем, что отфильтрован список и найдено мероприятие
      expect(find.text(eventTitle), findsWidgets);

      // Переходим на экран деталей мероприятия
      await tester.tap(find.text(eventTitle));
      await tester.pumpAndSettle();

      // Проверяем, что открылись детали мероприятия
      expect(find.text(eventTitle), findsWidgets);

      // Возвращаемся назад
      await tester.pageBack();
      await tester.pumpAndSettle();
    }

    // Проверяем, что кнопка создания мероприятия работает
    expect(find.byType(FloatingActionButton), findsOneWidget);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Проверка, что открылся экран создания мероприятия
    expect(find.text('Создать мероприятие'), findsOneWidget);

    // Возврат назад
    await tester.pageBack();
    await tester.pumpAndSettle();
  });
}
