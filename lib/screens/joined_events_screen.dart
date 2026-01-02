import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_app/widgets/event_card.dart'; // Подключаем общий виджет карточки
import 'package:my_app/screens/event_details_screen.dart'; // Для перехода в детали
import 'package:my_app/styles/styles.dart';

class JoinedEventsScreen extends StatefulWidget {
  @override
  _JoinedEventsScreenState createState() => _JoinedEventsScreenState();
}

class _JoinedEventsScreenState extends State<JoinedEventsScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> joinedEvents = [];
  List<dynamic> filteredEvents = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadJoinedEvents();
  }

  Future<void> _loadJoinedEvents() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('participants')
        .select('event_id, events(*, participants(event_id))')
        .eq('user_id', user.id);

    final loadedEvents =
        response.map((e) {
          final event = e['events'];
          event['participants'] = event['participants'] ?? [];
          return event;
        }).toList();

    setState(() {
      joinedEvents = loadedEvents;
      _applySearch();
    });
  }

  void _applySearch() {
    setState(() {
      filteredEvents =
          joinedEvents.where((event) {
            final title = event['title']?.toString().toLowerCase() ?? '';
            return title.contains(searchQuery.toLowerCase());
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Поиск среди моих мероприятий...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: TextStyle(color: Colors.white),
          onChanged: (value) {
            searchQuery = value;
            _applySearch();
          },
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body:
          filteredEvents.isEmpty
              ? Center(
                child: Text(
                  'Мероприятий не найдено',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: filteredEvents.length,
                itemBuilder: (context, index) {
                  final event = filteredEvents[index];
                  return EventCard(
                    event: event,
                    isJoined: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventDetailsScreen(event: event),
                        ),
                      );
                    },
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: iconColor,
                    ),
                  );
                },
              ),
    );
  }
}
