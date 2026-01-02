import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QrScanScreen extends StatefulWidget {
  final String eventId;

  const QrScanScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final supabase = Supabase.instance.client;
  final MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    _isProcessing = true;

    final barcode = capture.barcodes.first.rawValue;
    if (barcode == null) {
      _isProcessing = false;
      return;
    }

    final userId = barcode.trim();

    await controller.stop();

    final participant =
        await supabase
            .from('participants')
            .select()
            .eq('event_id', widget.eventId)
            .eq('user_id', userId)
            .maybeSingle();

    if (participant == null) {
      _showDialog('Участник не найден');
      return;
    }

    if (participant['checked_in'] == true) {
      _showDialog('Участник уже прошёл');
      return;
    }

    // 👉 Получаем имя пользователя по userId
    final userResponse =
        await supabase
            .from('users')
            .select('full_name')
            .eq('id', userId)
            .maybeSingle();

    final fullName =
        userResponse != null && userResponse['full_name'] != null
            ? userResponse['full_name']
            : 'Неизвестный пользователь';

    final result = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Подтвердить вход'),
            content: Text('Пропустить участника: $fullName?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Нет'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Да'),
              ),
            ],
          ),
    );

    if (result == true) {
      await supabase
          .from('participants')
          .update({'checked_in': true})
          .eq('event_id', widget.eventId)
          .eq('user_id', userId);

      _showDialog('Участник "$fullName" пропущен ✅', closeScreen: true);
    } else {
      await controller.start();
      _isProcessing = false;
    }
  }

  void _showDialog(String message, {bool closeScreen = false}) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Результат'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Закрыть диалог
                  if (closeScreen) {
                    Navigator.pop(context); // Выйти с экрана
                  } else {
                    _isProcessing = false;
                  }
                },
                child: Text('Ок'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Сканирование QR-кода')),
      body: MobileScanner(controller: controller, onDetect: _onDetect),
    );
  }
}
