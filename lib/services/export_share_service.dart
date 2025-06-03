import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/user_profile.dart';
import '../models/planet_position.dart';
import '../models/celestial_event.dart';
import 'package:intl/intl.dart';

class ExportShareService {
  // Platform-safe share methods - stub implementation for desktop  static Future<void> _shareFiles(List<String> filePaths, {String? text, String? subject}) async {
    // Stub implementation for desktop platforms
    log.log('Would share files: ${filePaths.join(', ')}');
    if (text != null) log.log('Text: $text');
    if (subject != null) log.log('Subject: $subject');
  }

  static Future<void> _shareText(String text, {String? subject}) async {
    // Stub implementation for desktop platforms
    log.log('Would share text: $text');
    if (subject != null) log.log('Subject: $subject');
  }// Unicode font support for Turkish characters
  static Future<pw.Font?> _getTurkishFont() async {
    try {
      // Try to load a Unicode-compatible font from assets
      // DejaVu Sans is a good choice for Turkish character support
      final fontData = await rootBundle.load('fonts/DejaVuSans.ttf');
      return pw.Font.ttf(fontData);
    } catch (e) {
      // If DejaVu Sans is not available, try Roboto
      try {
        final robotoData = await rootBundle.load('fonts/Roboto-Regular.ttf');
        return pw.Font.ttf(robotoData);      } catch (e2) {
        // If no custom fonts are available, return null to use PDF default
        // The PDF package's default font should handle most Turkish characters
        log.log('Custom font loading failed, using PDF default font for Turkish characters');
        return null;
      }
    }  }

  // Generate natal chart PDF
  static Future<File> generateNatalChartPdf(
    UserProfile profile,
    List<PlanetPosition> planetPositions,
    Map<String, dynamic>? horoscopeData,
  ) async {
    final pdf = pw.Document();
    
    // Load Turkish font for Unicode support
    pw.Font? turkishFont;    try {
      turkishFont = await _getTurkishFont();
      if (turkishFont != null) {
        log.log('Successfully loaded Turkish font for PDF');
      } else {
        log.log('Using PDF default font (should support basic Turkish characters)');
      }
    } catch (e) {
      log.log('Font loading failed, using PDF default font: $e');
      turkishFont = null;
    }
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        theme: turkishFont != null ? pw.ThemeData.withFont(
          base: turkishFont,
        ) : null,
        build: (pw.Context context) => [
          _buildPdfHeader(profile, turkishFont),
          pw.SizedBox(height: 20),
          _buildBirthInfo(profile, turkishFont),
          pw.SizedBox(height: 20),
          _buildPlanetPositionsTable(planetPositions, turkishFont),
          pw.SizedBox(height: 20),
          if (horoscopeData != null) _buildHoroscopeText(horoscopeData, turkishFont),
          pw.SizedBox(height: 20),
          _buildPdfFooter(turkishFont),
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/natal_chart_${profile.name}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }  // Generate astrology calendar PDF
  static Future<File> generateCalendarPdf(
    List<CelestialEvent> events,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final pdf = pw.Document();
    
    // Load Turkish font for Unicode support
    pw.Font? turkishFont;
    try {
      turkishFont = await _getTurkishFont();
      if (turkishFont != null) {        log.log('Successfully loaded Turkish font for calendar PDF');
      } else {
        log.log('Using PDF default font for calendar (should support basic Turkish characters)');
      }
    } catch (e) {
      log.log('Font loading failed for calendar, using PDF default font: $e');
      turkishFont = null;
    }
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        theme: turkishFont != null ? pw.ThemeData.withFont(
          base: turkishFont,
        ) : null,
        build: (pw.Context context) => [
          _buildCalendarHeader(startDate, endDate, turkishFont),
          pw.SizedBox(height: 20),
          _buildEventsTable(events, turkishFont),
          pw.SizedBox(height: 20),
          _buildPdfFooter(turkishFont),
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/astrology_calendar_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
      return file;
  }  // Share natal chart
  static Future<void> shareNatalChart(
    UserProfile profile,
    List<PlanetPosition> planetPositions,
    {Map<String, dynamic>? horoscopeData}
  ) async {
    try {
      final pdfFile = await generateNatalChartPdf(profile, planetPositions, horoscopeData);
      
      await _shareFiles(
        [pdfFile.path],
        text: '${profile.name} - Natal Harita\n\nAstroloji Master uygulaması ile oluşturuldu.',
        subject: '${profile.name} - Natal Harita',
      );
    } catch (e) {
      throw Exception('Natal harita paylaşılırken hata oluştu: $e');
    }
  }  // Share text summary
  static Future<void> shareTextSummary(
    UserProfile profile,
    List<PlanetPosition> planetPositions,
  ) async {
    final text = _generateTextSummary(profile, planetPositions);
    
    await _shareText(
      text,
      subject: '${profile.name} - Astroloji Özeti',
    );
  }// Share calendar events
  static Future<void> shareCalendarEvents(
    List<CelestialEvent> events,
    DateTime startDate,
    DateTime endDate,
  ) async {    try {
      final pdfFile = await generateCalendarPdf(events, startDate, endDate);
      
      await _shareFiles(
        [pdfFile.path],
        text: 'Astroloji Takvimi\n${DateFormat('d MMMM yyyy', 'tr_TR').format(startDate)} - ${DateFormat('d MMMM yyyy', 'tr_TR').format(endDate)}\n\nAstroloji Master uygulaması ile oluşturuldu.',
        subject: 'Astroloji Takvimi',
      );
    } catch (e) {
      throw Exception('Takvim paylaşılırken hata oluştu: $e');
    }
  }  // Share image (placeholder for future implementation)
  static Future<void> shareChartImage(Uint8List imageBytes, String filename) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsBytes(imageBytes);
    
    await _shareFiles(
      [file.path],
      text: 'Astroloji Master ile oluşturulan natal harita',
    );
  }

  // Generate social media friendly text
  static String generateSocialMediaText(
    UserProfile profile,
    List<PlanetPosition> planetPositions,
  ) {
    final sunSign = planetPositions.firstWhere(
      (p) => p.name == 'Sun',
      orElse: () => PlanetPosition(name: 'Sun', sign: 'Bilinmiyor', degree: 0),
    ).sign;
    
    final moonSign = planetPositions.firstWhere(
      (p) => p.name == 'Moon',
      orElse: () => PlanetPosition(name: 'Moon', sign: 'Bilinmiyor', degree: 0),
    ).sign;
    
    return '''🌟 Benim Astroloji Profilim 🌟

👤 ${profile.name}
📅 ${DateFormat('d MMMM yyyy', 'tr_TR').format(profile.birthDate)}
☉ Güneş Burcu: $sunSign
☽ Ay Burcu: $moonSign

✨ Astroloji Master ile keşfet!

#astroloji #burclar #natalharita #astrology''';
  }
  // Helper methods for PDF generation
  static pw.Widget _buildPdfHeader(UserProfile profile, pw.Font? turkishFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'NATAL HARİTA',
          style: pw.TextStyle(
            font: turkishFont,
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          profile.name,
          style: pw.TextStyle(
            font: turkishFont,
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Divider(),
      ],
    );
  }

  static pw.Widget _buildCalendarHeader(DateTime startDate, DateTime endDate, pw.Font? turkishFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'ASTROLOJİ TAKVİMİ',
          style: pw.TextStyle(
            font: turkishFont,
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          '${DateFormat('d MMMM yyyy', 'tr_TR').format(startDate)} - ${DateFormat('d MMMM yyyy', 'tr_TR').format(endDate)}',
          style: pw.TextStyle(
            font: turkishFont,
            fontSize: 16,
          ),
        ),
        pw.Divider(),
      ],
    );
  }
  static pw.Widget _buildBirthInfo(UserProfile profile, pw.Font? turkishFont) {
    return pw.Container(
      padding: pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Doğum Bilgileri',
            style: pw.TextStyle(
              font: turkishFont,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Text('Tarih: ', style: pw.TextStyle(font: turkishFont, fontWeight: pw.FontWeight.bold)),
              pw.Text(DateFormat('d MMMM yyyy', 'tr_TR').format(profile.birthDate), style: pw.TextStyle(font: turkishFont)),
            ],
          ),
          if (profile.birthTime != null) ...[
            pw.SizedBox(height: 5),
            pw.Row(
              children: [
                pw.Text('Saat: ', style: pw.TextStyle(font: turkishFont, fontWeight: pw.FontWeight.bold)),
                pw.Text(profile.birthTime!, style: pw.TextStyle(font: turkishFont)),
              ],
            ),
          ],
          if (profile.birthPlace != null) ...[
            pw.SizedBox(height: 5),
            pw.Row(
              children: [
                pw.Text('Yer: ', style: pw.TextStyle(font: turkishFont, fontWeight: pw.FontWeight.bold)),
                pw.Text(profile.birthPlace!, style: pw.TextStyle(font: turkishFont)),
              ],
            ),
          ],
          if (profile.latitude != null && profile.longitude != null) ...[
            pw.SizedBox(height: 5),
            pw.Row(
              children: [
                pw.Text('Koordinatlar: ', style: pw.TextStyle(font: turkishFont, fontWeight: pw.FontWeight.bold)),
                pw.Text('${profile.latitude!.toStringAsFixed(4)}, ${profile.longitude!.toStringAsFixed(4)}', style: pw.TextStyle(font: turkishFont)),
              ],
            ),
          ],
        ],
      ),
    );
  }
  static pw.Widget _buildPlanetPositionsTable(List<PlanetPosition> planetPositions, pw.Font? turkishFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Gezegen Pozisyonları',
          style: pw.TextStyle(
            font: turkishFont,
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey),
          columnWidths: {
            0: pw.FlexColumnWidth(2),
            1: pw.FlexColumnWidth(2),
            2: pw.FlexColumnWidth(1),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Gezegen',
                    style: pw.TextStyle(font: turkishFont, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Burç',
                    style: pw.TextStyle(font: turkishFont, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Derece',
                    style: pw.TextStyle(font: turkishFont, fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            ),
            ...planetPositions.map((planet) => pw.TableRow(
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(_getPlanetTurkishName(planet.name), style: pw.TextStyle(font: turkishFont)),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(planet.sign, style: pw.TextStyle(font: turkishFont)),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text('${planet.degree?.toStringAsFixed(1) ?? '0.0'}°', style: pw.TextStyle(font: turkishFont)),
                ),
              ],
            )).toList(),
          ],
        ),
      ],
    );
  }
  static pw.Widget _buildEventsTable(List<CelestialEvent> events, pw.Font? turkishFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Göksel Olaylar',
          style: pw.TextStyle(
            font: turkishFont,
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey),
          columnWidths: {
            0: pw.FlexColumnWidth(2),
            1: pw.FlexColumnWidth(3),
            2: pw.FlexColumnWidth(3),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Tarih',
                    style: pw.TextStyle(font: turkishFont, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Olay',
                    style: pw.TextStyle(font: turkishFont, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Açıklama',
                    style: pw.TextStyle(font: turkishFont, fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            ),
            ...events.map((event) => pw.TableRow(
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(
                    DateFormat('d MMM yyyy', 'tr_TR').format(event.dateTime),
                    style: pw.TextStyle(font: turkishFont),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(event.title, style: pw.TextStyle(font: turkishFont)),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(event.description, style: pw.TextStyle(font: turkishFont)),
                ),
              ],
            )).toList(),
          ],
        ),
      ],
    );
  }
  static pw.Widget _buildHoroscopeText(Map<String, dynamic> horoscopeData, pw.Font? turkishFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Günlük Yorum',
          style: pw.TextStyle(
            font: turkishFont,
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Text(
            horoscopeData['description'] ?? 'Yorum mevcut değil',
            style: pw.TextStyle(font: turkishFont),
            textAlign: pw.TextAlign.justify,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildPdfFooter(pw.Font? turkishFont) {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.Text(
          'Astroloji Master ile oluşturuldu',
          style: pw.TextStyle(
            font: turkishFont,
            fontSize: 10,
            color: PdfColors.grey,
          ),
        ),
        pw.Text(
          'Oluşturulma: ${DateFormat('d MMMM yyyy HH:mm', 'tr_TR').format(DateTime.now())}',
          style: pw.TextStyle(
            font: turkishFont,
            fontSize: 8,
            color: PdfColors.grey,
          ),
        ),
      ],
    );
  }

  // Generate text summary for sharing
  static String _generateTextSummary(
    UserProfile profile,
    List<PlanetPosition> planetPositions,
  ) {
    final buffer = StringBuffer();
    
    buffer.writeln('🌟 ${profile.name} - Astroloji Profili 🌟');
    buffer.writeln('');
    buffer.writeln('📅 Doğum: ${DateFormat('d MMMM yyyy', 'tr_TR').format(profile.birthDate)}');
    if (profile.birthTime != null) {
      buffer.writeln('🕐 Saat: ${profile.birthTime}');
    }
    if (profile.birthPlace != null) {
      buffer.writeln('📍 Yer: ${profile.birthPlace}');
    }
    buffer.writeln('');
    buffer.writeln('⭐ Gezegen Pozisyonları:');
      for (final planet in planetPositions) {
      final planetEmoji = _getPlanetEmoji(planet.name);
      final turkishName = _getPlanetTurkishName(planet.name);
      buffer.writeln('$planetEmoji $turkishName: ${planet.sign} (${planet.degree?.toStringAsFixed(1) ?? '0.0'}°)');
    }
    
    buffer.writeln('');
    buffer.writeln('✨ Astroloji Master ile keşfedildi');
    
    return buffer.toString();
  }

  // Helper methods for planet names and emojis
  static String _getPlanetTurkishName(String planet) {
    switch (planet.toLowerCase()) {
      case 'sun':
        return 'Güneş';
      case 'moon':
        return 'Ay';
      case 'mercury':
        return 'Merkür';
      case 'venus':
        return 'Venüs';
      case 'mars':
        return 'Mars';
      case 'jupiter':
        return 'Jüpiter';
      case 'saturn':
        return 'Satürn';
      case 'uranus':
        return 'Uranüs';
      case 'neptune':
        return 'Neptün';
      case 'pluto':
        return 'Plüton';
      default:
        return planet;
    }
  }
  static String _getPlanetEmoji(String planet) {
    switch (planet.toLowerCase()) {
      case 'sun':
        return '☉';
      case 'moon':
        return '☽';
      case 'mercury':
        return '☿';
      case 'venus':
        return '♀';
      case 'mars':
        return '♂';
      case 'jupiter':
        return '♃';
      case 'saturn':
        return '♄';
      case 'uranus':
        return '♅';
      case 'neptune':
        return '♆';
      case 'pluto':
        return '♇';
      default:
        return '⭐';
    }
  }

  // Missing methods required by natal_chart_screen.dart

  // Share as text with horoscope data
  static Future<void> shareAsText({
    required UserProfile profile,
    required List<PlanetPosition> planetPositions,
    Map<String, dynamic>? dailyHoroscope,
  }) async {
    final buffer = StringBuffer();
    
    buffer.writeln('🌟 ${profile.name} - Astroloji Profili 🌟');
    buffer.writeln('');
    buffer.writeln('📅 Doğum: ${DateFormat('d MMMM yyyy', 'tr_TR').format(profile.birthDate)}');
    if (profile.birthTime != null) {
      buffer.writeln('🕐 Saat: ${profile.birthTime}');
    }
    if (profile.birthPlace != null) {
      buffer.writeln('📍 Yer: ${profile.birthPlace}');
    }
    
    // Güneş ve Ay burcu
    final sunSign = planetPositions.firstWhere(
      (p) => p.name == 'Sun',
      orElse: () => PlanetPosition(name: 'Sun', sign: 'Bilinmiyor', degree: 0),
    ).sign;
    
    final moonSign = planetPositions.firstWhere(
      (p) => p.name == 'Moon',
      orElse: () => PlanetPosition(name: 'Moon', sign: 'Bilinmiyor', degree: 0),
    ).sign;
    
    buffer.writeln('');
    buffer.writeln('☉ Güneş Burcu: $sunSign');
    buffer.writeln('☽ Ay Burcu: $moonSign');
    
    // Günlük yorum varsa ekle
    if (dailyHoroscope != null) {
      buffer.writeln('');
      buffer.writeln('📊 Günlük Yorum:');
      buffer.writeln(dailyHoroscope['description'] ?? 'Yorum mevcut değil');
    }
    
    buffer.writeln('');
    buffer.writeln('⭐ Gezegen Pozisyonları:');
    for (final planet in planetPositions) {
      final planetEmoji = _getPlanetEmoji(planet.name);
      final turkishName = _getPlanetTurkishName(planet.name);
      buffer.writeln('$planetEmoji $turkishName: ${planet.sign} (${planet.degree?.toStringAsFixed(1) ?? '0.0'}°)');
    }    buffer.writeln('');
    buffer.writeln('✨ Astroloji Master ile keşfedildi');
    
    await _shareText(
      buffer.toString(),
      subject: '${profile.name} - Astroloji Profili',
    );
  }
  // Share as PDF
  static Future<void> shareAsPdf({
    required UserProfile profile,
    required List<PlanetPosition> planetPositions,
    Map<String, dynamic>? natalChartData,
    Map<String, dynamic>? dailyHoroscope,  }) async {
    try {
      final pdfFile = await generateNatalChartPdf(profile, planetPositions, dailyHoroscope);
      
      await _shareFiles(
        [pdfFile.path],
        text: '${profile.name} - Natal Harita\n\nAstroloji Master uygulaması ile oluşturuldu.',
        subject: '${profile.name} - Natal Harita',
      );
    } catch (e) {
      throw Exception('PDF paylaşılırken hata oluştu: $e');
    }
  }

  // Share to social media
  static Future<void> shareToSocialMedia({
    required UserProfile profile,
    required List<PlanetPosition> planetPositions,
  }) async {
    final sunSign = planetPositions.firstWhere(
      (p) => p.name == 'Sun',
      orElse: () => PlanetPosition(name: 'Sun', sign: 'Bilinmiyor', degree: 0),
    ).sign;
    
    final moonSign = planetPositions.firstWhere(
      (p) => p.name == 'Moon',
      orElse: () => PlanetPosition(name: 'Moon', sign: 'Bilinmiyor', degree: 0),
    ).sign;
    
    final socialText = '''🌟 Benim Astroloji Profilim 🌟

👤 ${profile.name}
📅 ${DateFormat('d MMMM yyyy', 'tr_TR').format(profile.birthDate)}
☉ Güneş Burcu: $sunSign
☽ Ay Burcu: $moonSign

✨ Astroloji Master ile keşfet!

#astroloji #burclar #natalharita #astrology''';
    
    await _shareText(
      socialText,
      subject: 'Astroloji Profili',
    );
  }

  // Export as PDF (save locally)
  static Future<bool> exportAsPdf({
    required UserProfile profile,
    required List<PlanetPosition> planetPositions,
    Map<String, dynamic>? natalChartData,
    Map<String, dynamic>? dailyHoroscope,
  }) async {
    try {
      await generateNatalChartPdf(profile, planetPositions, dailyHoroscope);
      
      // PDF başarıyla oluşturuldu ve kaydedildi
      return true;
    } catch (e) {
      throw Exception('PDF oluşturulurken hata oluştu: $e');
    }
  }
}
