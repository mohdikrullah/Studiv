// Helper untuk platform Mobile (Android/iOS) — menggunakan path_provider + share_plus
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Tidak digunakan di mobile — hanya ada di web stub
void downloadOnWeb(Uint8List bytes, String fileName) {
  // No-op di mobile
}

// ignore: unused_element
void _downloadOnWeb(Uint8List bytes, String fileName) {
  // No-op di mobile
}

/// Share gambar ke WhatsApp / Instagram / dll menggunakan share_plus
Future<void> shareImageOnMobile(Uint8List bytes, String text) async {
  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/studiv_achievement.png');
  await file.writeAsBytes(bytes);
  await Share.shareXFiles([XFile(file.path)], text: text);
}

/// Simpan gambar ke direktori dokumen aplikasi
Future<void> saveImageOnMobile(Uint8List bytes) async {
  final dir = await getApplicationDocumentsDirectory();
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final file = File('${dir.path}/studiv_achievement_$timestamp.png');
  await file.writeAsBytes(bytes);
}
