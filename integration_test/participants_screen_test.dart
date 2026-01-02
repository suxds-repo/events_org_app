import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:my_app/widgets/event_card.dart';

import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ParticipantsScreen test: через UI', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    await loginIfNeeded(tester);

    // === Шаг 2: Перейти на вкладку "Мои мероприятия" ===
    final myTab = find.byIcon(Icons.check_circle);
    expect(myTab, findsOneWidget);
    await tester.tap(myTab);
    await tester.pumpAndSettle();

    // === Шаг 3: Дождаться загрузки мероприятий ===
    final eventCardFinder = find.byType(EventCard);
    expect(eventCardFinder, findsWidgets);

    // === Шаг 4: Нажать на первое мероприятие ===
    await tester.tap(eventCardFinder.first);
    await tester.pumpAndSettle();

    // === Шаг 5: Нажать кнопку "Участники" (текст или иконка) ===
    final participantsButton = find.text('Участники');
    expect(participantsButton, findsOneWidget);
    await tester.tap(participantsButton);
    await tester.pumpAndSettle();

    // === Шаг 6: Проверка ParticipantsScreen ===
    expect(find.text('Участники'), findsOneWidget); // AppBar

    // Проверка хотя бы одного участника
    final participantTileFinder = find.byType(ListTile);
    expect(participantTileFinder, findsAtLeastNWidgets(1));

    // Дополнительно: имя, дата
    final subtitleFinder = find.descendant(
      of: participantTileFinder.first,
      matching: find.byType(Text),
    );
    expect(subtitleFinder, findsWidgets);
  });
}
