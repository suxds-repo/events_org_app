import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_app/screens/create_event_screen.dart'; // укажи правильный путь

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = 'https://njuyxyicazlxuzykqipq.supabase.co';
  const supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5qdXl4eWljYXpseHV6eWtxaXBxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ5MzYxMDAsImV4cCI6MjA2MDUxMjEwMH0.0_5r9dWXlPSOV-vEfcRcOQrqr9JrWlaGOK-AT8SmbSQ';

  testWidgets('CreateEventScreen creates event in Supabase', (tester) async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

    final supabase = Supabase.instance.client;

    // 🔐 Авторизация
    const email = 'ad@ad.ad';
    const password = 'ad';
    final signInResult = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final userId = signInResult.user?.id;
    expect(userId, isNotNull);

    // 🖼 Запускаем экран
    await tester.pumpWidget(MaterialApp(home: CreateEventScreen()));
    await tester.pumpAndSettle();

    const title = 'Тестовое мероприятие';
    const description = 'Описание теста';
    const address = 'Тестовая улица 123';
    const login = 'testlogin';
    const passwordEvent = 'testpass';
    const maxUsers = '10';

    // 🧪 Заполняем поля
    await tester.enterText(find.byType(TextField).at(0), title);
    await tester.enterText(find.byType(TextField).at(1), description);
    await tester.enterText(find.byType(TextField).at(2), address);
    await tester.enterText(find.byType(TextField).at(3), maxUsers);
    await tester.enterText(find.byType(TextField).at(4), login);
    await tester.enterText(find.byType(TextField).at(5), passwordEvent);

    await tester.pumpAndSettle();

    // ⏰ Пропускаем выбор времени/даты/фото

    // 🔘 Нажимаем "Создать"
    final createButton = find.text('Создать');

    // Скроллим до кнопки
    await tester.ensureVisible(createButton);
    await tester.pumpAndSettle();

    // Нажимаем
    await tester.tap(createButton);
    await tester.pumpAndSettle();

    // Ждём завершения вставки
    await Future.delayed(Duration(seconds: 2));

    // Проверяем, что мероприятие появилось в Supabase
    final response =
        await Supabase.instance.client
            .from('events')
            .select()
            .eq('title', 'Тестовое мероприятие')
            .maybeSingle();

    expect(response, isNotNull);
    expect(response?['description'], equals(description));
    expect(response?['adress'], equals(address));
    expect(response?['max_users'], equals(int.parse(maxUsers)));
    expect(response?['login'], equals(login));
    expect(response?['password'], equals(passwordEvent));

    // ❌ Удалим за собой
    if (response != null) {
      await supabase.from('events').delete().eq('id', response['id']);
    }
  });
}
