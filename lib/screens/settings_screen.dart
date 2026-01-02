import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edit_name_screen.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const SettingsScreen({required this.onLogout, super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? userName;
  String? userId;

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final response =
          await Supabase.instance.client
              .from('users')
              .select('full_name')
              .eq('id', user.id)
              .single();

      setState(() {
        userName = response['full_name'];
        userId = user.id;
      });
    }
  }

  void _navigateToEditName() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditNameScreen()),
    );
    fetchUserName();
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        centerTitle: true,
        backgroundColor: Colors.indigoAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 48,
              backgroundColor: Colors.indigo.shade100,
              child: const Icon(
                Icons.account_circle,
                size: 80,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 16),
            if (user != null)
              Column(
                children: [
                  Text(
                    user.email ?? 'Нет email',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (userName != null && userName!.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      userName!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ],
              ),

            const SizedBox(height: 30),

            if (userId != null)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Ваш QR-код',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      QrImageView(
                        data: userId!,
                        version: QrVersions.auto,
                        size: 160.0,
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _navigateToEditName,
              icon: const Icon(Icons.edit),
              label: const Text('Изменить имя'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.indigo,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 32),

            Divider(color: Colors.grey.shade300, thickness: 1.2),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Выйти из аккаунта'),
              onPressed: widget.onLogout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
