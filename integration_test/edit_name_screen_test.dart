import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/screens/edit_name_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = 'https://njuyxyicazlxuzykqipq.supabase.co';
  const supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5qdXl4eWljYXpseHV6eWtxaXBxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ5MzYxMDAsImV4cCI6MjA2MDUxMjEwMH0.0_5r9dWXlPSOV-vEfcRcOQrqr9JrWlaGOK-AT8SmbSQ';

  testWidgets('EditNameScreen updates user name in Supabase', (
    WidgetTester tester,
  ) async {
    // Инициализация Supabase перед использованием Supabase.instance
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

    // Выполнить вход (если необходимо)
    final supabase = Supabase.instance.client;

    if (supabase.auth.currentUser == null) {
      final response = await supabase.auth.signInWithPassword(
        email: 'ad@ad.ad',
        password: 'ad',
      );

      assert(response.user != null, 'Auth failed');
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return WillPopScope(
              onWillPop: () async {
                return true;
              },
              child: EditNameScreen(),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Ввод нового имени
    const newName = 'Иван Тестовый';
    await tester.enterText(find.byType(TextField), newName);
    await tester.pump();

    // Нажатие кнопки "Сохранить"
    await tester.tap(find.text('Сохранить'));
    await tester.pump(); // начало анимации
    await tester.pump(
      const Duration(seconds: 3),
    ); // подождать выполнения запроса
  });
}
