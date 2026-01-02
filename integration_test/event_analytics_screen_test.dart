import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/screens/event_analytics_screen.dart';
import 'package:my_app/main.dart' as app;
import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Live test: EventAnalyticsScreen shows data from Supabase', (
    WidgetTester tester,
  ) async {
    // Важно: замените на существующий eventId в вашей базе Supabase
    const eventId = '6c042a89-4edd-4e6a-b2a8-3730d6a0f76c';
    app.main();
    await tester.pumpAndSettle();
    await loginIfNeeded(tester);
    await tester.pumpWidget(
      const MaterialApp(home: EventAnalyticsScreen(eventId: eventId)),
    );

    // Ожидаем завершения загрузки
    await tester.pumpAndSettle(const Duration(seconds: 10));

    // Проверка базовых элементов аналитики
    expect(find.textContaining('Средняя оценка:'), findsOneWidget);
    expect(find.textContaining('Всего отзывов:'), findsOneWidget);
    expect(find.textContaining('Прошли по QR:'), findsOneWidget);

    // Проверка наличия кнопки графика
    expect(find.text('Показать график'), findsOneWidget);
    await tester.tap(find.text('Показать график'));
    await tester.pumpAndSettle();
    expect(find.text('Скрыть график'), findsOneWidget);

    // Проверка наличия отзывов (если они есть)
    expect(find.text('Отзывы:'), findsOneWidget);
    expect(find.byType(ListTile), findsWidgets); // хотя бы один отзыв
  });
}
