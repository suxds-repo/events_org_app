import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ParticipantsScreen extends StatelessWidget {
  final String eventId;

  const ParticipantsScreen({super.key, required this.eventId});

  Future<List<Map<String, dynamic>>> fetchParticipants(String eventId) async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase
          .from('participants')
          .select('user_id, joined_at, users(full_name)')
          .eq('event_id', eventId)
          .order('joined_at');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Ошибка загрузки участников: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Участники')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchParticipants(eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Ошибка при загрузке участников'));
          }

          final participants = snapshot.data!;

          if (participants.isEmpty) {
            return const Center(
              child: Text(
                'Пока нет участников',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: participants.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final participant = participants[index];
              final name =
                  participant['users']?['full_name']?.toString().trim();
              final joinedAt = participant['joined_at'];
              final date =
                  joinedAt != null
                      ? DateFormat(
                        'dd.MM.yyyy в HH:mm',
                      ).format(DateTime.parse(joinedAt))
                      : 'Дата неизвестна';

              return Card(
                elevation: 4,
                shadowColor: Colors.deepPurple.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    radius: 24,
                    child: Text(
                      (name?.isNotEmpty ?? false)
                          ? name![0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  title: Text(
                    name?.isNotEmpty == true ? name! : 'Без имени',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('Присоединился: $date'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
