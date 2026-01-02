import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditEventScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  EditEventScreen({required this.event});

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final supabase = Supabase.instance.client;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _adressController;
  late TextEditingController _loginController;
  late TextEditingController _passwordController;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();
  int _maxUsers = 10;
  String _status = 'активное';

  final List<String> _statuses = ['активное', 'завершено', 'отменено'];

  @override
  void initState() {
    super.initState();
    final event = widget.event;

    _titleController = TextEditingController(text: event['title']);
    _descriptionController = TextEditingController(text: event['description']);
    _adressController = TextEditingController(text: event['adress']);
    _loginController = TextEditingController(text: event['login']);
    _passwordController = TextEditingController(text: event['password']);

    _selectedDate = DateTime.tryParse(event['date']) ?? DateTime.now();

    _startTime =
        _parseTime(event['event_start']) ?? TimeOfDay(hour: 9, minute: 0);
    _endTime = _parseTime(event['event_end']) ?? TimeOfDay(hour: 18, minute: 0);
    _maxUsers = event['max_users'] ?? 10;
    _status = event['status'] ?? 'активное';
  }

  TimeOfDay? _parseTime(String? timeStr) {
    if (timeStr == null) return null;
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _confirmAndSave() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Подтверждение'),
            content: const Text('Сохранить изменения в мероприятии?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Сохранить'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      _saveChanges();
    }
  }

  Future<void> _saveChanges() async {
    final id = widget.event['id'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await supabase
          .from('events')
          .update({
            'title': _titleController.text.trim(),
            'description': _descriptionController.text.trim(),
            'adress': _adressController.text.trim(),
            'login': _loginController.text.trim(),
            'password': _passwordController.text.trim(),
            'date': _selectedDate.toIso8601String().split('T').first,
            'event_start': _startTime.format(context),
            'event_end': _endTime.format(context),
            'max_users': _maxUsers,
            'status': _status,
          })
          .eq('id', id);

      if (context.mounted) {
        Navigator.pop(context); // закрыть прогресс
        Navigator.pop(context); // закрыть экран редактирования
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Мероприятие успешно обновлено')),
        );
      }
    } catch (e) {
      Navigator.pop(context); // закрыть прогресс
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ошибка при сохранении')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Редактировать мероприятие')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(_titleController, 'Название', Icons.title),
            const SizedBox(height: 12),
            _buildTextField(
              _descriptionController,
              'Описание',
              Icons.description,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            _buildTextField(_adressController, 'Адрес', Icons.location_on),
            const SizedBox(height: 12),
            _buildTextField(_loginController, 'Логин', Icons.person),
            const SizedBox(height: 12),
            _buildTextField(
              _passwordController,
              'Пароль',
              Icons.lock,
              obscureText: true,
            ),
            const SizedBox(height: 12),

            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('Дата'),
              subtitle: Text(
                '${_selectedDate.day.toString().padLeft(2, '0')}.'
                '${_selectedDate.month.toString().padLeft(2, '0')}.'
                '${_selectedDate.year}',
              ),
              onTap: _pickDate,
            ),

            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Начало'),
              subtitle: Text(_startTime.format(context)),
              onTap: () => _pickTime(true),
            ),

            ListTile(
              leading: const Icon(Icons.access_time_outlined),
              title: const Text('Окончание'),
              subtitle: Text(_endTime.format(context)),
              onTap: () => _pickTime(false),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.people),
                const SizedBox(width: 12),
                Expanded(
                  child: Slider(
                    value: _maxUsers.toDouble(),
                    min: 1,
                    max: 100,
                    divisions: 99,
                    label: _maxUsers.toString(),
                    onChanged: (value) {
                      setState(() {
                        _maxUsers = value.toInt();
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Статус',
                border: OutlineInputBorder(),
              ),
              value: _statuses.contains(_status) ? _status : null,
              items:
                  _statuses.map((status) {
                    return DropdownMenuItem(value: status, child: Text(status));
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _status = value;
                  });
                }
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmAndSave,
                child: const Text('Сохранить изменения'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscureText = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    );
  }
}
