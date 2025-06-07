import 'package:flutter/material.dart';

class PlanetInfoPanel extends StatelessWidget {
  final String planetName;
  final String sign;
  final double? degree;
  final List<Map<String, dynamic>> aspects;
  final VoidCallback onClose;

  const PlanetInfoPanel({
    super.key,
    required this.planetName,
    required this.sign,
    this.degree,
    required this.aspects,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getPlanetNameInTurkish(planetName),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClose,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Burç: $sign',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          if (degree != null)            Text(
              'Derece: ${degree!.toStringAsFixed(1)}°',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          const SizedBox(height: 12),
          if (aspects.isNotEmpty) ...[
            const Text(
              'Aspektler:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...aspects.map((aspect) => _buildAspectItem(aspect)),
          ] else
            const Text(
              'Bu gezegenin önemli aspekti bulunmuyor.',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildAspectItem(Map<String, dynamic> aspect) {
    Color aspectColor = aspect['aspectData']['color'];
    String aspectName = _getAspectNameInTurkish(aspect['aspectName']);
    String otherPlanet = _getPlanetNameInTurkish(aspect['otherPlanet']);
    double orb = aspect['orb'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: aspectColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$aspectName ile $otherPlanet (${orb.toStringAsFixed(1)}° orb)',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _getPlanetNameInTurkish(String planetName) {
    const Map<String, String> planetNames = {
      'Sun': 'Güneş',
      'Moon': 'Ay',
      'Mercury': 'Merkür',
      'Venus': 'Venüs',
      'Mars': 'Mars',
      'Jupiter': 'Jüpiter',
      'Saturn': 'Satürn',
      'Uranus': 'Uranüs',
      'Neptune': 'Neptün',
      'Pluto': 'Plüton',
    };
    return planetNames[planetName] ?? planetName;
  }

  String _getAspectNameInTurkish(String aspectName) {
    const Map<String, String> aspectNames = {
      'Conjunction': 'Konjünksiyon',
      'Opposition': 'Karşıtlık',
      'Trine': 'Trigon',
      'Square': 'Kare',
      'Sextile': 'Sextil',
      'Quincunx': 'Quincunx',
    };
    return aspectNames[aspectName] ?? aspectName;
  }
}
