class UserBirthInfo {
  String? name;
  DateTime? birthDate;
  String? birthTime; // "HH:mm" formatında
  String? birthPlace;
  double? latitude; // Eklendi
  double? longitude; // Eklendi

  UserBirthInfo({
    this.name,
    this.birthDate,
    this.birthTime,
    this.birthPlace,
    this.latitude, // Eklendi
    this.longitude, // Eklendi
  });
}
