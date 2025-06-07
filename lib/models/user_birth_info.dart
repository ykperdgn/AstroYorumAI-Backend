class UserBirthInfo {
  String? name;
  DateTime? birthDate;
  String? birthTime; // "HH:mm" formatında
  String? birthPlace;
  double? latitude;
  double? longitude;

  UserBirthInfo({
    this.name,
    this.birthDate,
    this.birthTime,
    this.birthPlace,
    this.latitude,
    this.longitude,
  });

  /// Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'birthDate': birthDate?.toIso8601String(),
      'birthTime': birthTime,
      'birthPlace': birthPlace,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Create from JSON
  factory UserBirthInfo.fromJson(Map<String, dynamic> json) {
    return UserBirthInfo(
      name: json['name'] as String?,
      birthDate: json['birthDate'] != null
          ? DateTime.tryParse(json['birthDate'])
          : null,
      birthTime: json['birthTime'] as String?,
      birthPlace: json['birthPlace'] as String?,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  /// Validation method
  bool isValid() {
    return name?.isNotEmpty == true &&
        birthDate != null &&
        birthTime?.isNotEmpty == true &&
        latitude != null &&
        longitude != null &&
        latitude! >= -90 &&
        latitude! <= 90 &&
        longitude! >= -180 &&
        longitude! <= 180;
  }

  @override
  String toString() {
    return 'UserBirthInfo(name: $name, birthDate: $birthDate, birthTime: $birthTime, birthPlace: $birthPlace, lat: $latitude, lon: $longitude)';
  }
}
