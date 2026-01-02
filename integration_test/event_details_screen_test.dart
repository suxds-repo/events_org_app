import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/screens/event_details_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mocktail/mocktail.dart';

// --- Моки ---
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockAuth extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

void main() {
  late MockSupabaseClient mockSupabase;
  late MockAuth mockAuth;
  late MockUser mockUser;

  final testEvent = {
    'id': 1,
    'title': 'Тестовое мероприятие',
    'description': 'Описание теста',
    'date': '2025-06-01',
    'event_start': '10:00',
    'event_end': '12:00',
    'adress': 'ул. Тестовая, 1',
    'login': 'test_login',
    'password': 'test_pass',
    'created_by': 'user-123',
    'max_users': 10,
    'status': 'Открыто',
    'image_url': '',
  };

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockAuth = MockAuth();
    mockUser = MockUser();

    // Подменяем текущего пользователя
    when(() => mockUser.id).thenReturn('user-456');
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockSupabase.auth).thenReturn(mockAuth);
    Supabase.initialize(
      url: 'https://njuyxyicazlxuzykqipq.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5qdXl4eWljYXpseHV6eWtxaXBxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ5MzYxMDAsImV4cCI6MjA2MDUxMjEwMH0.0_5r9dWXlPSOV-vEfcRcOQrqr9JrWlaGOK-AT8SmbSQ',
    );
  });

  testWidgets('Отображается заголовок мероприятия и кнопка присоединения', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: EventDetailsScreen(event: testEvent)),
    );

    // Проверяем наличие заголовка
    expect(find.text('Тестовое мероприятие'), findsOneWidget);

    // Поля логина и пароля
    expect(find.byType(TextField), findsNWidgets(2));

    // Кнопка присоединения
    expect(find.text('Присоединиться'), findsOneWidget);
  });

  // Дополнительные тесты:
  // - ввод логина и пароля
  // - нажатие на кнопку "Присоединиться"
  // - отображение сообщения об ошибке
  // - отображение сообщения об успешном входе
  // и др.
}
