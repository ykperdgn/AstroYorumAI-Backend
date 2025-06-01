// Stub implementation for share functionality on unsupported platforms

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
    print('Sharing files: ${files.map((f) => f.path).join(', ')}');
    if (text != null) print('Text: $text');
    if (subject != null) print('Subject: $subject');
  }

  static Future<void> share(
    String text, {
    String? subject,
  }) async {
    // Stub implementation - do nothing on unsupported platforms
    print('Sharing text: $text');
    if (subject != null) print('Subject: $subject');
  }
}
