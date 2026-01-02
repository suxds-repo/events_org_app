import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;

  bool _isLoading = false;

  void _showMessage(String message, {bool isError = false}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.redAccent : Colors.green,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final res = await _supabase.auth.signInWithPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );
      if (res.user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on AuthException catch (e) {
      _showMessage(e.message, isError: true);
    } catch (e) {
      _showMessage('Произошла неизвестная ошибка', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final res = await _supabase.auth.signUp(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );
      if (res.user != null) {
        _showMessage('Письмо для подтверждения отправлено!');
      }
    } on AuthException catch (e) {
      _showMessage(e.message, isError: true);
    } catch (e) {
      _showMessage('Произошла неизвестная ошибка', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Вход / Регистрация'),
        centerTitle: true,
        backgroundColor: Colors.indigoAccent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Добро пожаловать!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _email,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Некорректный email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Пароль',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите пароль';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : Column(
                          children: [
                            ElevatedButton(
                              onPressed: _signIn,
                              child: const Text('Войти'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                                backgroundColor: Colors.indigoAccent,
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                            ),
                            TextButton(
                              onPressed: _signUp,
                              child: const Text('Регистрация'),
                            ),
                          ],
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
