import 'package:flutter/material.dart';
import '../services/astrology_api_service.dart';
import '../services/extended_astrology_api_service.dart';
import '../services/astrology_backend_service.dart' as backend;
import '../services/export_share_service.dart';
import '../models/planet_position.dart';
import '../models/user_profile.dart';
import '../widgets/planet_positions_table.dart';
import '../widgets/zodiac_wheel_display.dart';
import '../widgets/enhanced_error_display.dart';
import 'package:intl/intl.dart';
import 'transit_screen.dart';

class NatalChartScreen extends StatefulWidget {
  final String name;
  final DateTime birthDate;
  final String? birthTime;
  final String? birthPlace;
  final double? latitude; // Eklendi
  final double? longitude; // Eklendi

  const NatalChartScreen({
    super.key,
    required this.name,
    required this.birthDate,
    this.birthTime,
    this.birthPlace,
    this.latitude, // Eklendi
    this.longitude, // Eklendi
  });
  @override
  State<NatalChartScreen> createState() => _NatalChartScreenState();
}

class _NatalChartScreenState extends State<NatalChartScreen> {
  Map<String, dynamic>? _dailyHoroscope;
  Map<String, dynamic>? _natalChartData;
  Map<String, dynamic>? _weeklyHoroscope;
  Map<String, dynamic>? _monthlyHoroscope;
  bool _isLoadingDailyHoroscope = true;
  bool _isLoadingNatalChart = true;
  bool _isLoadingWeeklyHoroscope = false;
  bool _isLoadingMonthlyHoroscope = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchNatalChartData();
  }

  Future<void> _fetchNatalChartData() async {
    setState(() {
      _isLoadingNatalChart = true;
      _errorMessage = null;
    }); // Log configuration for debugging
    // backend.AstrologyBackendService.logConfiguration();

    if (widget.birthTime == null || widget.birthTime!.isEmpty) {
      setState(() {
        _isLoadingNatalChart = false;
        _errorMessage = 'Doğum haritası için doğum saati gereklidir.';
      });
      return;
    } // Koordinat kontrolü ve default değerler
    double latitude = widget.latitude ?? 41.0082; // Istanbul default
    double longitude = widget.longitude ?? 28.9784; // Istanbul default

    if (widget.latitude == null || widget.longitude == null) {
      // Using Istanbul default coordinates when location is not available
    }

    final String formattedDate =
        DateFormat('yyyy-MM-dd').format(widget.birthDate);

    final chartData = await backend.AstrologyBackendService.getNatalChart(
      date: formattedDate,
      time: widget.birthTime!,
      latitude: latitude, // Default veya gerçek latitude
      longitude: longitude, // Default veya gerçek longitude
    );
    if (mounted) {
      // Widget ağaçta hala varsa state güncelle
      setState(() {
        _natalChartData = chartData;
        _isLoadingNatalChart = false;
        if (chartData == null) {
          _errorMessage =
              'Doğum haritası verileri alınamadı. Backend API bağlantı sorunu.';
        } else if (chartData.containsKey('error')) {
          // Enhanced error message handling with better user experience
          String detailedError = chartData['error'] ?? 'Bilinmeyen hata';
          String userMessage = chartData['user_message'] ?? '';
          String solution = chartData['solution'] ?? '';
          bool isCorsError = chartData['is_cors_error'] == true;
          String platform = chartData['platform'] ?? 'unknown';

          _errorMessage = detailedError;

          if (userMessage.isNotEmpty) {
            _errorMessage = '${_errorMessage ?? ''}\n\n$userMessage';
          }
          if (solution.isNotEmpty) {
            _errorMessage =
                '${_errorMessage ?? ''}\n\nÇözüm önerileri:\n$solution';
          }

          // Add web-specific guidance
          if (isCorsError && platform == 'web') {
            _errorMessage =
                '${_errorMessage ?? ''}\n\n⚠️ Web Uygulaması Kısıtlaması: Bu sorun yalnızca web tarayıcısında yaşanır. Mobil uygulamayı tercih edebilirsiniz.';
          }
        } else {
          // Natal chart verisi başarıyla alındıysa, Güneş burcunu buradan alıp günlük yorumu getir
          if (chartData['planets']?['Sun'] != null) {
            // Yeni format: chartData['planets']['Sun']['sign']
            var sunData = chartData['planets']['Sun'];
            String? sunSignFromApi;
            if (sunData is String) {
              // Eski format uyumluluğu için
              sunSignFromApi = sunData;
            } else if (sunData is Map) {
              // Yeni format
              sunSignFromApi = sunData['sign'];
            }
            if (sunSignFromApi != null) {
              _fetchDailyHoroscope(sunSignFromApi);
              _fetchWeeklyHoroscope(sunSignFromApi);
              _fetchMonthlyHoroscope(sunSignFromApi);
            }
          }
        }
      });
    }
  }

  Future<void> _fetchDailyHoroscope(String sign) async {
    setState(() {
      _isLoadingDailyHoroscope = true;
    });
    final horoscope =
        await AstrologyApiService.getDailyHoroscope(sign: sign.toLowerCase());
    if (mounted) {
      setState(() {
        _dailyHoroscope = horoscope;
        _isLoadingDailyHoroscope = false;
      });
    }
  }

  Future<void> _fetchWeeklyHoroscope(String sign) async {
    setState(() {
      _isLoadingWeeklyHoroscope = true;
    });
    final horoscope = await ExtendedAstrologyApiService.getHoroscope(
        sign: sign.toLowerCase(), period: 'week');
    if (mounted) {
      setState(() {
        _weeklyHoroscope = horoscope;
        _isLoadingWeeklyHoroscope = false;
      });
    }
  }

  Future<void> _fetchMonthlyHoroscope(String sign) async {
    setState(() {
      _isLoadingMonthlyHoroscope = true;
    });
    final horoscope = await ExtendedAstrologyApiService.getHoroscope(
        sign: sign.toLowerCase(), period: 'month');
    if (mounted) {
      setState(() {
        _monthlyHoroscope = horoscope;
        _isLoadingMonthlyHoroscope = false;
      });
    }
  }

  List<PlanetPosition> _getPlanetPositionsFromData(
      Map<String, dynamic>? chartData) {
    if (chartData == null || chartData['planets'] == null) {
      return [];
    }
    final Map<String, dynamic> planetsMap = chartData['planets'];
    // Gezegenlerin gösterim sırasını belirleyebiliriz
    const planetOrder = [
      'Sun',
      'Moon',
      'Mercury',
      'Venus',
      'Mars',
      'Jupiter',
      'Saturn',
      'Uranus',
      'Neptune',
      'Pluto'
    ];
    List<PlanetPosition> positions = [];
    for (String planetName in planetOrder) {
      if (planetsMap.containsKey(planetName)) {
        var planetData = planetsMap[planetName];
        String sign;
        double? degree;

        if (planetData is String) {
          // Eski format uyumluluğu
          sign = planetData;
          degree = null;
        } else if (planetData is Map) {
          // Yeni format
          sign = planetData['sign'] ?? 'Bilinmiyor';
          degree = planetData['deg']?.toDouble();
        } else {
          sign = 'Bilinmiyor';
          degree = null;
        }

        positions.add(PlanetPosition(
          name: planetName,
          sign: sign,
          degree: degree,
        ));
      }
    }
    return positions;
  }

  @override
  Widget build(BuildContext context) {
    String displayName = widget.name;
    String displayBirthDate = DateFormat('dd.MM.yyyy').format(widget.birthDate);
    String displayBirthTime = widget.birthTime ?? 'Bilinmiyor';
    String displayBirthPlace = widget.birthPlace ?? 'Bilinmiyor';
    String displayCoordinates = (widget.latitude != null &&
            widget.longitude != null)
        ? 'Koordinatlar: ${widget.latitude!.toStringAsFixed(4)}, ${widget.longitude!.toStringAsFixed(4)}'
        : 'Koordinatlar: Bilinmiyor';

    if (_isLoadingNatalChart) {
      return Scaffold(
        appBar: AppBar(title: const Text('Doğum Haritası Yükleniyor...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hata')),
        body: SingleChildScrollView(
          child: EnhancedErrorDisplay(
            errorMessage: _errorMessage,
            errorData: _natalChartData?.containsKey('error') == true
                ? _natalChartData
                : null,
            onRetry: _fetchNatalChartData,
            context: 'Doğum Haritası',
          ),
        ),
      );
    }
    List<PlanetPosition> planetPositions = _getPlanetPositionsFromData(
        _natalChartData); // Güneş burcu için yeni format desteği - API verilerini doğru şekilde al
    String sunSign = 'Bilinmiyor';
    if (_natalChartData?['planets']?['Güneş'] != null) {
      // Türkçe anahtar kontrolü (API serviste çeviri yapılıyor)
      var sunData = _natalChartData!['planets']['Güneş'];
      if (sunData is String) {
        sunSign = sunData;
      } else if (sunData is Map) {
        sunSign = sunData['sign'] ?? 'Bilinmiyor';
      }
    } else if (_natalChartData?['planets']?['Sun'] != null) {
      // İngilizce anahtar kontrolü (fallback)
      var sunData = _natalChartData!['planets']['Sun'];
      if (sunData is String) {
        sunSign = sunData;
      } else if (sunData is Map) {
        sunSign = sunData['sign'] ?? 'Bilinmiyor';
      }
    } // Eğer hala bilinmiyor ise ve doğum tarihi varsa, basit hesaplama yap
    if (sunSign == 'Bilinmiyor') {
      sunSign = _calculateSunSignFromDate(widget.birthDate);
    }

    String ascendantSign = _natalChartData?['ascendant'] ?? 'Bilinmiyor';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doğum Haritası'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.share),
            onSelected: (value) => _handleExportShare(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share_text',
                child: Row(
                  children: [
                    Icon(Icons.text_fields),
                    SizedBox(width: 8),
                    Text('Metin Olarak Paylaş'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share_pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf),
                    SizedBox(width: 8),
                    Text('PDF Olarak Paylaş'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share_social',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Sosyal Medya'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export_pdf',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('PDF İndir'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            // Zodyak çarkı görseli
            ZodiacWheelDisplay(
              planetData: _natalChartData?['planets'],
              ascendantSign: ascendantSign,
            ),
            const SizedBox(height: 8),
            Text('Kullanıcı: $displayName',
                style: Theme.of(context).textTheme.headlineSmall),
            Text('Doğum Tarihi: $displayBirthDate'),
            Text('Doğum Saati: $displayBirthTime'),
            if (displayBirthPlace != 'Bilinmiyor')
              Text('Doğum Yeri: $displayBirthPlace'),
            if (widget.latitude != null && widget.longitude != null)
              Text(displayCoordinates,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            const SizedBox(height: 20),
            Text('Güneş Burcu: $sunSign',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            Text('Yükselen Burç: $ascendantSign',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 24),
            Text('Gezegen Konumları',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            planetPositions.isNotEmpty
                ? PlanetPositionsTable(planets: planetPositions)
                : const Text('Gezegen konumları alınamadı.'),
            const SizedBox(
                height:
                    20), // Günlük Yorum Kısmı            if (_isLoadingDailyHoroscope)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator())),
            if (!_isLoadingDailyHoroscope && _dailyHoroscope != null)
              Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Günlük Yorum (${_dailyHoroscope!["current_date"]}) - $sunSign',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(_dailyHoroscope!["description"] ??
                          'Yorum bulunamadı.'),
                      const SizedBox(height: 10),
                      Text(
                          'Uyumluluk: ${_dailyHoroscope!["compatibility"] ?? '-'}'),
                      Text('Mod: ${_dailyHoroscope!["mood"] ?? '-'}'),
                      Text('Renk: ${_dailyHoroscope!["color"] ?? '-'}'),
                      Text(
                          'Şanslı Sayı: ${_dailyHoroscope!["lucky_number"] ?? '-'}'),
                      Text(
                          'Şanslı Zaman: ${_dailyHoroscope!["lucky_time"] ?? '-'}'),
                    ],
                  ),
                ),
              ),
            if (!_isLoadingDailyHoroscope &&
                _dailyHoroscope == null &&
                sunSign != 'Bilinmiyor')
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(
                            'Günlük burç yorumu ($sunSign için) alınamadı.',
                            style:
                                const TextStyle(fontStyle: FontStyle.italic))),
                  ],
                ),
              ),
            if (_isLoadingWeeklyHoroscope)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator())),
            if (!_isLoadingWeeklyHoroscope && _weeklyHoroscope != null)
              Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Haftalık Yorum - $sunSign',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(_weeklyHoroscope!["description"] ??
                          'Yorum bulunamadı.'),
                    ],
                  ),
                ),
              ),
            if (!_isLoadingWeeklyHoroscope &&
                _weeklyHoroscope == null &&
                sunSign != 'Bilinmiyor')
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(
                            'Haftalık burç yorumu ($sunSign için) alınamadı.',
                            style:
                                const TextStyle(fontStyle: FontStyle.italic))),
                  ],
                ),
              ),
            if (_isLoadingMonthlyHoroscope)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator())),
            if (!_isLoadingMonthlyHoroscope && _monthlyHoroscope != null)
              Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Aylık Yorum - $sunSign',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(_monthlyHoroscope!["description"] ??
                          'Yorum bulunamadı.'),
                    ],
                  ),
                ),
              ),
            if (!_isLoadingMonthlyHoroscope &&
                _monthlyHoroscope == null &&
                sunSign != 'Bilinmiyor')
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(
                            'Aylık burç yorumu ($sunSign için) alınamadı.',
                            style:
                                const TextStyle(fontStyle: FontStyle.italic))),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            const Divider(thickness: 1.2, color: Colors.deepPurple),
            const SizedBox(height: 16), // Ekstra bilgi kutusu
            const Card(
              color: Colors.deepPurple,
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.white, size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Haritanızdaki gezegen konumları ve burç yorumları yalnızca bilgilendirme amaçlıdır. Astrolojik analizler profesyonel danışmanlık yerine geçmez.',
                        style: TextStyle(fontSize: 13, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16), // Transit Analizi butonu
            ElevatedButton.icon(
              icon: const Icon(Icons.timeline),
              label: const Text('Transit Analizi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => TransitScreen(
                            birthDate: widget.birthDate,
                            sunSign: sunSign,
                          )),
                );
              },
            ),
            const SizedBox(height: 40),
            const Center(
                child: Text("Bu veriler flatlib kullanılarak hesaplanmıştır.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey))),
          ],
        ),
      ),
    );
  }

  // Doğum tarihinden güneş burcunu hesaplayan yardımcı metod
  String _calculateSunSignFromDate(DateTime birthDate) {
    final day = birthDate.day;
    final month = birthDate.month;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return "Koç";
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return "Boğa";
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20))
      return "İkizler";
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return "Yengeç";
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return "Aslan";
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return "Başak";
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22))
      return "Terazi";
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21))
      return "Akrep";
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return "Yay";
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return "Oğlak";
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return "Kova";
    if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) return "Balık";

    return "Koç"; // Fallback
  }

  Future<void> _handleExportShare(String action) async {
    try {
      final profile = UserProfile(
        id: widget.name.hashCode.toString(),
        name: widget.name,
        birthDate: widget.birthDate,
        birthTime: widget.birthTime,
        birthPlace: widget.birthPlace,
        latitude: widget.latitude,
        longitude: widget.longitude,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      switch (action) {
        case 'share_text':
          await ExportShareService.shareAsText(
            profile: profile,
            planetPositions: _getPlanetPositionsFromData(_natalChartData),
            dailyHoroscope: _dailyHoroscope,
          );
          break;
        case 'share_pdf':
          await ExportShareService.shareAsPdf(
            profile: profile,
            planetPositions: _getPlanetPositionsFromData(_natalChartData),
            natalChartData: _natalChartData,
            dailyHoroscope: _dailyHoroscope,
          );
          break;
        case 'share_social':
          await ExportShareService.shareToSocialMedia(
            profile: profile,
            planetPositions: _getPlanetPositionsFromData(_natalChartData),
          );
          break;
        case 'export_pdf':
          final success = await ExportShareService.exportAsPdf(
            profile: profile,
            planetPositions: _getPlanetPositionsFromData(_natalChartData),
            natalChartData: _natalChartData,
            dailyHoroscope: _dailyHoroscope,
          );
          if (!mounted) return;
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PDF başarıyla indirildi!'),
                backgroundColor: Colors.green,
              ),
            );
          }
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('İşlem başarısız: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
