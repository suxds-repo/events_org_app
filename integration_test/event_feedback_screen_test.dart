import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/main.dart' as app;
import 'package:my_app/widgets/event_card.dart';
import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('EventFeedbackScreen: отправка отзыва', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    await loginIfNeeded(tester);

    // Проверка нижней навигации
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Переход на вкладку "Участвую"
    final myTab = find.byIcon(Icons.check_circle);
    expect(myTab, findsOneWidget);
    await tester.tap(myTab);
    await tester.pumpAndSettle();

    // Ожидаем карточку мероприятия
    final joinedEvent = find.byType(EventCard).first;
    expect(joinedEvent, findsOneWidget);

    await tester.tap(joinedEvent);
    await tester.pumpAndSettle();

    // Кнопка "Оставить отзыв"
    final feedbackButton = find.text('Оставить отзыв');
    expect(feedbackButton, findsOneWidget);
    // Прокручиваем до кнопки
    await tester.ensureVisible(feedbackButton);
    await tester.pumpAndSettle();

    await tester.tap(feedbackButton);
    await tester.pumpAndSettle();

    // Проверяем наличие элементов по ключам
    expect(find.byKey(const Key('rating_slider')), findsOneWidget);
    expect(find.byKey(const Key('comment_field')), findsOneWidget);
    expect(find.byKey(const Key('anonymous_checkbox')), findsOneWidget);
    expect(find.byKey(const Key('submit_button')), findsOneWidget);

    // Изменяем слайдер
    await tester.drag(
      find.byKey(const Key('rating_slider')),
      const Offset(100, 0),
    );
    await tester.pump();

    // Ввод комментария
    await tester.enterText(
      find.byKey(const Key('comment_field')),
      'Это был отличный ивент!',
    );
    await tester.pump();

    // Включаем чекбокс
    await tester.tap(find.byKey(const Key('anonymous_checkbox')));
    await tester.pump();

    // Отправляем
    await tester.tap(find.byKey(const Key('submit_button')));
    await tester.pumpAndSettle();

    // Проверка snackbar
    expect(find.text('Спасибо за отзыв!'), findsOneWidget);
  });
}
