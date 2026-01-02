import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditNameScreen extends StatefulWidget {
  @override
  _EditNameScreenState createState() => _EditNameScreenState();
}

class _EditNameScreenState extends State<EditNameScreen> {
  final _controller = TextEditingController();
  bool _loading = false;

  Future<void> _saveName() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final name = _controller.text.trim();

    if (userId != null && name.isNotEmpty) {
      setState(() => _loading = true);
      await Supabase.instance.client.from('users').upsert({
        'id': userId,
        'full_name': name,
      });
      setState(() => _loading = false);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Изменить имя')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Новое имя',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _saveName,
                child:
                    _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Сохранить'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
