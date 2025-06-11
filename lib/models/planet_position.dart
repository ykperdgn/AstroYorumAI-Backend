class PlanetPosition {
  final String name;
  final String sign;
  final double? degree; // Burç içi derece bilgisi

  PlanetPosition({
    required this.name,
    required this.sign,
    this.degree,
  });
}
