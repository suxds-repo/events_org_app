import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allEvents = [];
  List<Map<String, dynamic>> _filteredEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
    _searchController.addListener(_filterEvents);
  }

  Future<void> _fetchEvents() async {
    try {
      final response = await supabase.from('events').select();
      setState(() {
        _allEvents = List<Map<String, dynamic>>.from(response);
        _filteredEvents = _allEvents;
        _isLoading = false;
      });
    } catch (e) {
      print('Ошибка при получении мероприятий: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterEvents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEvents =
          _allEvents.where((event) {
            final title = (event['title'] ?? '').toString().toLowerCase();
            return title.contains(query);
          }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Поиск мероприятий')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Поиск по названию',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child:
                        _filteredEvents.isEmpty
                            ? const Center(
                              child: Text('Мероприятия не найдены'),
                            )
                            : ListView.builder(
                              itemCount: _filteredEvents.length,
                              itemBuilder: (context, index) {
                                final event = _filteredEvents[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  elevation: 2,
                                  child: ListTile(
                                    title: Text(event['title'] ?? ''),
                                    subtitle: Text(event['date'] ?? ''),
                                    trailing: Text(event['status'] ?? ''),
                                    onTap: () {
                                      // Можно реализовать переход к деталям мероприятия
                                    },
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }
}
