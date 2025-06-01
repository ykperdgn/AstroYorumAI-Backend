import 'package:flutter/material.dart';
import 'dart:math';
import 'planet_info_panel.dart';

class ZodiacWheelDisplay extends StatefulWidget {
  final Map<String, dynamic>? planetData;
  final String? ascendantSign;

  const ZodiacWheelDisplay({Key? key, this.planetData, this.ascendantSign}) : super(key: key);

  @override
  _ZodiacWheelDisplayState createState() => _ZodiacWheelDisplayState();
}

class _ZodiacWheelDisplayState extends State<ZodiacWheelDisplay> {
  String? _selectedPlanet;
  Offset? _tapPosition;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTapDown: (TapDownDetails details) {
            setState(() {
              _tapPosition = details.localPosition;
              _selectedPlanet = _detectPlanetTap(details.localPosition);
            });
          },
          child: Container(
            width: double.infinity,
            height: 360,
            margin: const EdgeInsets.all(8.0),
            child: CustomPaint(
              painter: _ZodiacWheelPainter(
                planetData: widget.planetData, 
                ascendantSign: widget.ascendantSign,
                selectedPlanet: _selectedPlanet,
              ),
              child: Center(),
            ),
          ),
        ),
        if (_selectedPlanet != null && widget.planetData != null)
          Positioned(
            top: 20,
            right: 20,
            child: PlanetInfoPanel(
              planetName: _selectedPlanet!,
              sign: _getPlanetSign(_selectedPlanet!),
              degree: _getPlanetDegree(_selectedPlanet!),
              aspects: _getPlanetAspects(_selectedPlanet!),
              onClose: () {
                setState(() {
                  _selectedPlanet = null;
                });
              },
            ),
          ),
      ],
    );
  }

  String? _detectPlanetTap(Offset tapPosition) {
    if (widget.planetData == null) return null;
    
    const double containerSize = 360;
    final Offset center = Offset(containerSize / 2, containerSize / 2);
    const double radius = containerSize / 2 - 40;
    const double planetRadius = radius - 15;
    const double anglePerSign = 2 * pi / 12;
    
    const List<String> zodiacSigns = [
      'Koç', 'Boğa', 'İkizler', 'Yengeç', 'Aslan', 'Başak',
      'Terazi', 'Akrep', 'Yay', 'Oğlak', 'Kova', 'Balık'
    ];

    for (String planetName in widget.planetData!.keys) {
      var planetInfo = widget.planetData![planetName];
      if (planetInfo is Map && planetInfo.containsKey('sign') && planetInfo.containsKey('deg')) {
        final sign = planetInfo['sign'] as String;
        final degree = (planetInfo['deg'] as num).toDouble();
        
        final signIndex = zodiacSigns.indexOf(sign);
        if (signIndex != -1) {
          final signProgress = degree / 30.0;
          final totalAngle = -pi / 2 + signIndex * anglePerSign + signProgress * anglePerSign;
          
          final planetX = center.dx + planetRadius * cos(totalAngle);
          final planetY = center.dy + planetRadius * sin(totalAngle);
          
          // Check if tap is within planet circle (radius 12)
          final distance = sqrt(pow(tapPosition.dx - planetX, 2) + pow(tapPosition.dy - planetY, 2));
          if (distance <= 15) {
            return planetName;
          }
        }
      }
    }
    return null;
  }

  String _getPlanetSign(String planetName) {
    var planetInfo = widget.planetData![planetName];
    if (planetInfo is Map && planetInfo.containsKey('sign')) {
      return planetInfo['sign'] as String;
    }
    return 'Bilinmiyor';
  }

  double? _getPlanetDegree(String planetName) {
    var planetInfo = widget.planetData![planetName];
    if (planetInfo is Map && planetInfo.containsKey('deg')) {
      return (planetInfo['deg'] as num).toDouble();
    }
    return null;
  }

  List<Map<String, dynamic>> _getPlanetAspects(String planetName) {
    // This will be implemented with the aspect calculation from the painter
    List<Map<String, dynamic>> aspects = [];
    
    // Calculate aspects for the selected planet
    final painter = _ZodiacWheelPainter(planetData: widget.planetData, ascendantSign: widget.ascendantSign);
    final allAspects = painter.calculateAspectsPublic();
    
    for (var aspect in allAspects) {
      if (aspect['planet1'] == planetName) {
        aspects.add({
          ...aspect,
          'otherPlanet': aspect['planet2'],
        });
      } else if (aspect['planet2'] == planetName) {
        aspects.add({
          ...aspect,
          'otherPlanet': aspect['planet1'],
        });
      }
    }
    
    return aspects;
  }
}

class _ZodiacWheelPainter extends CustomPainter {
  final Map<String, dynamic>? planetData;
  final String? ascendantSign;
  final String? selectedPlanet;
  
  _ZodiacWheelPainter({this.planetData, this.ascendantSign, this.selectedPlanet});

  static const List<String> zodiacSigns = [
    'Koç', 'Boğa', 'İkizler', 'Yengeç', 'Aslan', 'Başak',
    'Terazi', 'Akrep', 'Yay', 'Oğlak', 'Kova', 'Balık'
  ];

  // Gezegen simgeleri (Unicode karakterler)
  static const Map<String, String> planetSymbols = {
    'Sun': '☉',
    'Moon': '☽',
    'Mercury': '☿',
    'Venus': '♀',
    'Mars': '♂',
    'Jupiter': '♃',
    'Saturn': '♄',
    'Uranus': '♅',
    'Neptune': '♆',
    'Pluto': '♇',
  };

  static const Map<String, Color> planetColors = {
    'Sun': Colors.orange,
    'Moon': Colors.blue,
    'Mercury': Colors.yellow,
    'Venus': Colors.green,
    'Mars': Colors.red,
    'Jupiter': Colors.purple,
    'Saturn': Colors.brown,
    'Uranus': Colors.cyan,
    'Neptune': Colors.indigo,
    'Pluto': Colors.grey,
  };

  // Astrolojik aspektler ve toleransları
  static const Map<String, Map<String, dynamic>> aspects = {
    'Conjunction': {'angle': 0, 'tolerance': 8, 'color': Colors.red, 'strokeWidth': 3.0},
    'Opposition': {'angle': 180, 'tolerance': 8, 'color': Colors.red, 'strokeWidth': 2.5},
    'Trine': {'angle': 120, 'tolerance': 6, 'color': Colors.blue, 'strokeWidth': 2.0},
    'Square': {'angle': 90, 'tolerance': 6, 'color': Colors.orange, 'strokeWidth': 2.0},
    'Sextile': {'angle': 60, 'tolerance': 4, 'color': Colors.green, 'strokeWidth': 1.5},
    'Quincunx': {'angle': 150, 'tolerance': 3, 'color': Colors.purple, 'strokeWidth': 1.0},
  };

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 20;
    final Paint circlePaint = Paint()
      ..color = Colors.deepPurple.shade50
      ..style = PaintingStyle.fill;
    final Paint borderPaint = Paint()
      ..color = Colors.deepPurple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Ana çember
    canvas.drawCircle(center, radius, circlePaint);
    canvas.drawCircle(center, radius, borderPaint);

    // İç çember (gezegenlerin yerleşeceği alan)
    final innerRadius = radius - 35;
    canvas.drawCircle(center, innerRadius, Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill);
    canvas.drawCircle(center, innerRadius, Paint()
      ..color = Colors.deepPurple.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1);

    // 12 burç segmenti
    final double anglePerSign = 2 * pi / 12;
    final textStyle = TextStyle(color: Colors.deepPurple[900], fontSize: 12, fontWeight: FontWeight.bold);
    
    for (int i = 0; i < 12; i++) {
      final angle = -pi / 2 + i * anglePerSign;
      final x = center.dx + (radius - 20) * cos(angle);
      final y = center.dy + (radius - 20) * sin(angle);
      
      // Burç ismi
      final textSpan = TextSpan(text: zodiacSigns[i], style: textStyle);
      final textPainter = TextPainter(text: textSpan, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
      
      // Segment çizgileri
      final segX = center.dx + radius * cos(angle);
      final segY = center.dy + radius * sin(angle);
      final innerSegX = center.dx + innerRadius * cos(angle);
      final innerSegY = center.dy + innerRadius * sin(angle);
      canvas.drawLine(Offset(innerSegX, innerSegY), Offset(segX, segY), 
        Paint()..color = Colors.deepPurple.shade300..strokeWidth = 1);
    }

    // Gezegenleri çiz
    _drawPlanets(canvas, center, innerRadius, anglePerSign);

    // Aspekt çizgilerini çiz
    _drawAspects(canvas, center, innerRadius - 30, anglePerSign);

    // Yükselen işareti
    _drawAscendant(canvas, center, radius, anglePerSign);
  }
  // Aspekt hesaplama ve çizim metodları
  List<Map<String, dynamic>> _calculateAspects() {
    return calculateAspectsPublic();
  }

  List<Map<String, dynamic>> calculateAspectsPublic() {
    if (planetData == null) return [];
    
    List<Map<String, dynamic>> aspectList = [];
    List<String> planetNames = planetData!.keys.toList();
    
    for (int i = 0; i < planetNames.length; i++) {
      for (int j = i + 1; j < planetNames.length; j++) {
        String planet1 = planetNames[i];
        String planet2 = planetNames[j];
        
        var planet1Data = planetData![planet1];
        var planet2Data = planetData![planet2];
        
        if (planet1Data is Map && planet2Data is Map &&
            planet1Data.containsKey('sign') && planet1Data.containsKey('deg') &&
            planet2Data.containsKey('sign') && planet2Data.containsKey('deg')) {
          
          double angle1 = _getAbsoluteAngle(planet1Data['sign'], planet1Data['deg']);
          double angle2 = _getAbsoluteAngle(planet2Data['sign'], planet2Data['deg']);
          
          double aspectAngle = (angle2 - angle1).abs();
          if (aspectAngle > 180) aspectAngle = 360 - aspectAngle;
          
          // Aspekt kontrolü
          for (String aspectName in aspects.keys) {
            var aspectData = aspects[aspectName]!;
            double targetAngle = aspectData['angle'];
            double tolerance = aspectData['tolerance'];
            
            if ((aspectAngle - targetAngle).abs() <= tolerance) {
              aspectList.add({
                'planet1': planet1,
                'planet2': planet2,
                'angle1': angle1,
                'angle2': angle2,
                'aspectName': aspectName,
                'aspectData': aspectData,
                'orb': (aspectAngle - targetAngle).abs(),
              });
              break; // Her gezegen çifti için sadece bir aspekt
            }
          }
        }
      }
    }
    
    return aspectList;
  }

  double _getAbsoluteAngle(String sign, num degree) {
    int signIndex = zodiacSigns.indexOf(sign);
    if (signIndex == -1) return 0.0;
    return signIndex * 30.0 + degree.toDouble();
  }

  void _drawAspects(Canvas canvas, Offset center, double radius, double anglePerSign) {
    List<Map<String, dynamic>> aspectList = _calculateAspects();
    
    for (var aspect in aspectList) {
      String planet1 = aspect['planet1'];
      String planet2 = aspect['planet2'];
      double angle1 = aspect['angle1'] * pi / 180 - pi / 2; // UI koordinat sistemine çevir
      double angle2 = aspect['angle2'] * pi / 180 - pi / 2;
      var aspectData = aspect['aspectData'];
      
      // Gezegen konumları
      double planetX1 = center.dx + radius * cos(angle1);
      double planetY1 = center.dy + radius * sin(angle1);
      double planetX2 = center.dx + radius * cos(angle2);
      double planetY2 = center.dy + radius * sin(angle2);
      
      // Aspekt çizgisi
      Paint aspectPaint = Paint()
        ..color = aspectData['color'].withOpacity(0.6)
        ..strokeWidth = aspectData['strokeWidth']
        ..style = PaintingStyle.stroke;
      
      // Konjünksiyon haricinde çizgi çiz (konjünksiyon çok yakın olduğu için görünmez)
      if (aspect['aspectName'] != 'Conjunction') {
        canvas.drawLine(Offset(planetX1, planetY1), Offset(planetX2, planetY2), aspectPaint);
      }
    }
  }

  void _drawPlanets(Canvas canvas, Offset center, double radius, double anglePerSign) {
    if (planetData == null) return;

    planetData!.forEach((planetName, planetInfo) {
      if (planetInfo is Map && planetInfo.containsKey('sign') && planetInfo.containsKey('deg')) {
        final sign = planetInfo['sign'] as String;
        final degree = (planetInfo['deg'] as num).toDouble();
        
        final signIndex = zodiacSigns.indexOf(sign);
        if (signIndex != -1) {
          // Burç içindeki pozisyon (0-30 derece arası)
          final signProgress = degree / 30.0;
          final totalAngle = -pi / 2 + signIndex * anglePerSign + signProgress * anglePerSign;
          
          // Gezegen konumu
          final planetRadius = radius - 15;
          final planetX = center.dx + planetRadius * cos(totalAngle);
          final planetY = center.dy + planetRadius * sin(totalAngle);
          
          // Gezegen simgesi
          final symbol = planetSymbols[planetName] ?? planetName[0];
          final color = planetColors[planetName] ?? Colors.deepPurple;
          
          // Seçili gezegen için vurgulu arka plan
          bool isSelected = planetName == selectedPlanet;
          double circleRadius = isSelected ? 15 : 12;
          
          // Arka plan dairesi
          canvas.drawCircle(Offset(planetX, planetY), circleRadius, Paint()
            ..color = (isSelected ? color.withOpacity(0.4) : color.withOpacity(0.2))
            ..style = PaintingStyle.fill);
          canvas.drawCircle(Offset(planetX, planetY), circleRadius, Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = isSelected ? 3 : 2);
          
          // Gezegen simgesi
          final symbolSpan = TextSpan(
            text: symbol,
            style: TextStyle(
              color: isSelected ? color.withOpacity(0.9) : color.withOpacity(0.8),
              fontSize: isSelected ? 16 : 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          );
          final symbolPainter = TextPainter(
            text: symbolSpan,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
          );
          symbolPainter.layout();
          symbolPainter.paint(canvas, Offset(
            planetX - symbolPainter.width / 2,
            planetY - symbolPainter.height / 2,
          ));
        }
      }
    });
  }

  void _drawAscendant(Canvas canvas, Offset center, double radius, double anglePerSign) {
    if (ascendantSign == null) return;

    final sign = ascendantSign!;
    final signIndex = zodiacSigns.indexOf(sign);
    if (signIndex == -1) return;

    final double angle = -pi / 2 + signIndex * anglePerSign;
    final double x = center.dx + (radius - 10) * cos(angle);
    final double y = center.dy + (radius - 10) * sin(angle);

    // Yükselen işareti simgesi (Unicode karakter)
    final String symbol = '↑';

    // Yükselen işareti dairesi
    canvas.drawCircle(Offset(x, y), 8, Paint()
      ..color = Colors.yellow.withOpacity(0.8)
      ..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(x, y), 8, Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);

    // Yükselen işareti simgesi
    final TextSpan textSpan = TextSpan(
      text: symbol,
      style: TextStyle(
        color: Colors.orange,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
    final TextPainter textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
