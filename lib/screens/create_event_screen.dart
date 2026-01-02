import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../image_uploader.dart';

class CreateEventScreen extends StatefulWidget {
  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  String _formatTimeOfDayTo24(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _maxUsersController = TextEditingController();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  String? imageUrl;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _endTime = TimeOfDay(hour: 12, minute: 0);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart)
          _startTime = picked;
        else
          _endTime = picked;
      });
    }
  }

  Future<void> _createEvent() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _maxUsersController.text.isEmpty ||
        _loginController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Пожалуйста, заполните все обязательные поля')),
      );
      return;
    }

    final maxUsers = int.tryParse(_maxUsersController.text);
    if (maxUsers == null || maxUsers <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Количество участников должно быть числом')),
      );
      return;
    }

    await Supabase.instance.client.from('events').insert({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'date': _selectedDate.toIso8601String(),
      'event_start':
          '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}:00',
      'event_end':
          '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}:00',
      'created_by': user.id,
      'max_users': maxUsers,
      'login': _loginController.text.isEmpty ? null : _loginController.text,
      'password':
          _passwordController.text.isEmpty ? null : _passwordController.text,
      'adress': _addressController.text,
      'image_url': imageUrl,
      'status': 'активное',
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Мероприятие создано!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Создать мероприятие')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Название'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Описание'),
            ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Адрес'),
            ),
            TextField(
              controller: _maxUsersController,
              decoration: InputDecoration(labelText: 'Максимум участников'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _loginController,
              decoration: InputDecoration(labelText: 'Логин'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Пароль'),
            ),

            Row(
              children: [
                Text(
                  'Дата: ${_selectedDate.toLocal().toIso8601String().substring(0, 10)}',
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: _pickDate,
                ),
              ],
            ),
            Row(
              children: [
                Text('Начало: ${_formatTimeOfDayTo24(_startTime)}'),
                IconButton(
                  icon: Icon(Icons.access_time),
                  onPressed: () => _pickTime(true),
                ),
              ],
            ),
            Row(
              children: [
                Text('Конец: ${_formatTimeOfDayTo24(_endTime)}'),
                IconButton(
                  icon: Icon(Icons.access_time),
                  onPressed: () => _pickTime(false),
                ),
              ],
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final url = await uploadImageFromPhone();
                if (url != null) {
                  setState(() {
                    imageUrl = url;
                  });
                }
              },
              child: Text(
                imageUrl == null ? 'Загрузить фото' : 'Фото загружено',
              ),
            ),
            if (imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Image.network(imageUrl!, height: 150),
              ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _createEvent, child: Text('Создать')),
          ],
        ),
      ),
    );
  }
}
