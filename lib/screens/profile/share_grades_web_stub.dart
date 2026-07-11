// Helper untuk platform Web — menggunakan dart:html untuk download file
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

/// Trigger download file gambar di browser web
void _downloadOnWeb(Uint8List bytes, String fileName) {
  final blob = html.Blob([bytes], 'image/png');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}

/// Alias agar bisa dipanggil dari share_grades_screen.dart
void downloadOnWeb(Uint8List bytes, String fileName) => _downloadOnWeb(bytes, fileName);

/// Stub — share di web tidak tersedia (download saja)
Future<void> shareImageOnMobile(Uint8List bytes, String text) async {
  _downloadOnWeb(bytes, 'studiv_achievement.png');
}

/// Stub — save di web = download
Future<void> saveImageOnMobile(Uint8List bytes) async {
  _downloadOnWeb(bytes, 'studiv_achievement.png');
}
