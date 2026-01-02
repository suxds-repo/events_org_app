import 'package:flutter/material.dart';
import 'package:my_app/screens/event_analytics_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'participants_screen.dart';
import 'edit_event_screen.dart'; // добавлено
import 'qr_scan_screen.dart';
import 'event_feedback_screen.dart'; // импорт экрана отзывов

class EventDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  EventDetailsScreen({required this.event});

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> participants = [];
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    final data = await supabase
        .from('participants')
        .select('user_id')
        .eq('event_id', widget.event['id']);
    setState(() {
      participants = data;
    });
  }

  Future<void> _joinEvent() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final eventLogin = widget.event['login'];
    final eventPassword = widget.event['password'];
    final maxUsers = widget.event['max_users'];

    if (_loginController.text != eventLogin ||
        _passwordController.text != eventPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Неверный логин или пароль')));
      return;
    }

    final alreadyJoined = participants.any((p) => p['user_id'] == userId);
    if (alreadyJoined) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Вы уже присоединились к событию')),
      );
      return;
    }

    if (participants.length >= maxUsers) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Достигнут лимит участников')));
      return;
    }

    setState(() {
      _isJoining = true;
    });

    try {
      await supabase.from('participants').insert({
        'event_id': widget.event['id'],
        'user_id': userId,
      });
      await _loadParticipants();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Вы присоединились к мероприятию!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при присоединении к мероприятию')),
      );
    } finally {
      setState(() {
        _isJoining = false;
      });
    }
  }

  Future<void> _leaveEvent() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await supabase
          .from('participants')
          .delete()
          .eq('event_id', widget.event['id'])
          .eq('user_id', userId);

      await _loadParticipants();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Вы вышли из мероприятия')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при выходе из мероприятия')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final currentUserId = supabase.auth.currentUser?.id;
    final joined = participants.any((p) => p['user_id'] == currentUserId);
    final isCreator = event['created_by'] == currentUserId;

    // Проверяем, прошло ли время окончания мероприятия
    final DateTime now = DateTime.now();
    DateTime endDateTime;
    try {
      endDateTime = DateTime.parse('${event['date']}T${event['event_end']}');
    } catch (_) {
      endDateTime = DateTime.now().subtract(const Duration(days: 1));
    }
    final bool eventEnded = now.isAfter(endDateTime);

    return Scaffold(
      appBar: AppBar(
        title: Text(event['title']),
        actions: [
          IconButton(
            icon: Icon(Icons.group),
            tooltip: 'Список участников',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ParticipantsScreen(eventId: event['id']),
                ),
              );
            },
          ),
          if (isCreator)
            IconButton(
              icon: Icon(Icons.edit),
              tooltip: 'Редактировать',
              onPressed: () async {
                final updatedEvent = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditEventScreen(event: event),
                  ),
                );

                if (updatedEvent != null) {
                  setState(() {
                    widget.event.addAll(updatedEvent);
                  });
                }
              },
            ),
          if (isCreator)
            ElevatedButton(
              onPressed: () async {
                final shouldRefresh = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QrScanScreen(eventId: widget.event['id']),
                  ),
                );

                if (shouldRefresh == true) {
                  _loadParticipants(); // обновляем список участников
                }
              },
              child: Text('QR-код'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (event['image_url'] != null &&
                event['image_url'].toString().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  event['image_url'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 12.0,
                ),
                child: Column(
                  children: [
                    _infoTile(
                      Icons.description,
                      'Описание',
                      event['description'] ?? 'Нет описания',
                    ),
                    _infoTile(
                      Icons.location_on,
                      'Адрес',
                      event['adress'] ?? 'Не указан',
                    ),
                    _infoTile(
                      Icons.date_range,
                      'Дата',
                      _formatDate(event['date']),
                    ),
                    _infoTile(
                      Icons.access_time,
                      'Время',
                      '${_formatTime(event['event_start'])} - ${_formatTime(event['event_end'])}',
                    ),
                    _infoTile(
                      Icons.group,
                      'Участники',
                      '${participants.length} / ${event['max_users']}',
                    ),
                    _infoTile(
                      Icons.info_outline,
                      'Статус',
                      event['status'] ?? '',
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            if (!joined) ...[
              _inputField(_loginController, 'Логин', Icons.person),
              SizedBox(height: 12),
              _inputField(
                _passwordController,
                'Пароль',
                Icons.lock,
                obscure: true,
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isJoining ? null : _joinEvent,
                  child:
                      _isJoining
                          ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Text('Присоединиться'),
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'Вы уже участвуете в этом мероприятии',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: _leaveEvent,
                  child: Text('Выйти из мероприятия'),
                ),
              ),
            ],
            if (joined && eventEnded) ...[
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventFeedbackScreen(eventId: event['id']),
                    ),
                  );

                  if (result == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Отзыв успешно отправлен')),
                    );
                  }
                },
                icon: Icon(Icons.feedback_outlined),
                label: Text('Оставить отзыв'),
              ),
            ],
            if (joined && isCreator) ...[
              ElevatedButton.icon(
                icon: Icon(Icons.analytics),
                label: Text('Аналитика'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => EventAnalyticsScreen(eventId: event['id']),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _inputField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }

  String _formatTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      final hour = parts[0].padLeft(2, '0');
      final minute = parts[1].padLeft(2, '0');
      return '$hour:$minute';
    } catch (_) {
      return timeStr;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}.' +
          '${date.month.toString().padLeft(2, '0')}.' +
          '${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
