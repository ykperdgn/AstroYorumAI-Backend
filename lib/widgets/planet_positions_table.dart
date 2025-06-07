import 'package:flutter/material.dart';
import '../models/planet_position.dart';

class PlanetPositionsTable extends StatelessWidget {
  final List<PlanetPosition> planets;

  const PlanetPositionsTable({super.key, required this.planets});

  @override
  Widget build(BuildContext context) {    return Table(
      border: TableBorder.all(color: Colors.grey.shade400, width: 0.5), // Kenarlık rengi ve kalınlığı ayarlandı
      columnWidths: const <int, TableColumnWidth>{
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.deepPurple[50]), // Başlık satırı rengi biraz daha açık
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0), // Dikey padding artırıldı
              child: Text('Gezegen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), // Font boyutu ayarlandı
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
              child: Text('Burç', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
              child: Text('Derece', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ],
        ),
        ...planets.map((planet) => TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0), // Hücre içi padding
              child: Text(planet.name, style: const TextStyle(fontSize: 14)), // Font boyutu ayarlandı
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: Text(planet.sign, style: const TextStyle(fontSize: 14)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: Text(
                planet.degree != null ? '${planet.degree!.toStringAsFixed(1)}°' : '-',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ],
        )),
      ],
    );
  }
}
