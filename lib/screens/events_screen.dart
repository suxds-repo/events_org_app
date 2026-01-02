import 'package:flutter/material.dart';
import 'package:my_app/screens/create_event_screen.dart';
import 'package:my_app/screens/event_details_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_app/widgets/event_card.dart';
import 'package:my_app/styles/styles.dart';

class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> events = [];
  List<dynamic> filteredEvents = [];
  Set<String> joinedEventIds = {};
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _loadJoinedEvents();
  }

  Future<void> _loadEvents() async {
    final response = await supabase
        .from('events')
        .select('*, participants:participants(event_id)')
        .order('date');

    setState(() {
      events = response;
      _applySearch();
    });
  }

  Future<void> _loadJoinedEvents() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('participants')
        .select('event_id')
        .eq('user_id', user.id);

    final ids =
        (response as List<dynamic>)
            .map<String>((e) => e['event_id'] as String)
            .toSet();

    setState(() {
      joinedEventIds = ids;
    });
  }

  void _applySearch() {
    setState(() {
      filteredEvents =
          events.where((event) {
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
            hintText: 'Поиск мероприятий...',
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
              ? Center(child: Text('Мероприятий не найдено'))
              : ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: filteredEvents.length,
                itemBuilder: (context, index) {
                  final event = filteredEvents[index];
                  final eventId = event['id'] as String;
                  final isJoined = joinedEventIds.contains(eventId);

                  return EventCard(
                    event: event,
                    isJoined: isJoined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventDetailsScreen(event: event),
                        ),
                      ).then((_) => _loadEvents());
                    },
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: iconColor,
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateEventScreen()),
          ).then((_) {
            _loadEvents();
            _loadJoinedEvents();
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
