import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventFeedbackScreen extends StatefulWidget {
  final String eventId;

  const EventFeedbackScreen({super.key, required this.eventId});

  @override
  State<EventFeedbackScreen> createState() => _EventFeedbackScreenState();
}

class _EventFeedbackScreenState extends State<EventFeedbackScreen> {
  final supabase = Supabase.instance.client;

  final TextEditingController _commentController = TextEditingController();
  int _rating = 3;
  bool _anonymous = false;
  bool _submitting = false;

  Future<void> _submitFeedback() async {
    setState(() {
      _submitting = true;
    });

    final userId = _anonymous ? null : supabase.auth.currentUser?.id;

    await supabase.from('event_feedback').insert({
      'event_id': widget.eventId,
      'user_id': userId,
      'rating': _rating,
      'comment': _commentController.text,
    });

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Спасибо за отзыв!')));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Оставить отзыв')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Оценка мероприятия:'),
            Slider(
              key: const Key('rating_slider'),
              value: _rating.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: _rating.toString(),
              onChanged: (value) {
                setState(() {
                  _rating = value.toInt();
                });
              },
            ),
            TextField(
              key: const Key('comment_field'),
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Комментарий',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            CheckboxListTile(
              key: const Key('anonymous_checkbox'),
              title: const Text('Анонимно'),
              value: _anonymous,
              onChanged: (val) {
                setState(() {
                  _anonymous = val ?? false;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              key: const Key('submit_button'),
              onPressed: _submitting ? null : _submitFeedback,
              child: const Text('Отправить'),
            ),
          ],
        ),
      ),
    );
  }
}
