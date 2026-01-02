import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://njuyxyicazlxuzykqipq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5qdXl4eWljYXpseHV6eWtxaXBxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ5MzYxMDAsImV4cCI6MjA2MDUxMjEwMH0.0_5r9dWXlPSOV-vEfcRcOQrqr9JrWlaGOK-AT8SmbSQ',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // <-- добавлено
      title: 'Организация мероприятий',
      initialRoute: '/login',
      routes: {
        '/home': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}
