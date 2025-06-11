// Stub implementation for share functionality on unsupported platforms
import 'dart:developer' as log;

class XFile {
  final String path;
  XFile(this.path);
}

class Share {
  static Future<void> shareXFiles(
    List<XFile> files, {
    String? text,
    String? subject,
  }) async {
    // Stub implementation - do nothing on unsupported platforms
    log.log('Sharing files: ${files.map((f) => f.path).join(', ')}');
    if (text != null) log.log('Text: $text');
    if (subject != null) log.log('Subject: $subject');
  }

  static Future<void> share(
    String text, {
    String? subject,
  }) async {
    // Stub implementation - do nothing on unsupported platforms
    log.log('Sharing text: $text');
    if (subject != null) log.log('Subject: $subject');
  }
}
