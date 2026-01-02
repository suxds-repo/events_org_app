import 'dart:typed_data';
import 'dart:io' as io; // используем только для mobile
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

Future<String?> uploadImageFromPhone() async {
  final picker = ImagePicker();
  final pickedImage = await picker.pickImage(source: ImageSource.gallery);

  if (pickedImage == null) return null;

  Uint8List fileBytes;
  String fileName;
  String mimeType;

  if (kIsWeb) {
    // Flutter Web: используем bytes напрямую
    fileBytes = await pickedImage.readAsBytes();
    fileName = '${DateTime.now().millisecondsSinceEpoch}_${pickedImage.name}';
    mimeType = lookupMimeType(pickedImage.name) ?? 'image/jpeg';
  } else {
    // Mobile/Desktop
    final file = io.File(pickedImage.path);
    fileBytes = await file.readAsBytes();
    fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
    mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
  }

  final storage = Supabase.instance.client.storage;

  try {
    await storage
        .from('event-images')
        .uploadBinary(
          fileName,
          fileBytes,
          fileOptions: FileOptions(contentType: mimeType, upsert: true),
        );

    final publicUrl = storage.from('event-images').getPublicUrl(fileName);
    return publicUrl;
  } catch (e) {
    print('Image upload error: $e');
    return null;
  }
}
