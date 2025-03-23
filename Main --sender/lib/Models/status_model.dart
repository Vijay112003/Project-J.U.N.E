import 'dart:convert';

class StatusInfo {
  final int brightness;
  final int volume;
  final String power;
  final int battery;
  final bool wifi;  // Changed from String to bool
  final bool bluetooth;  // Changed from String to bool

  StatusInfo({
    required this.brightness,
    required this.volume,
    required this.power,
    required this.battery,
    required this.wifi,
    required this.bluetooth,
  });

  // Factory constructor to create an instance from JSON
  factory StatusInfo.fromJson(Map<String, dynamic> json) {
    return StatusInfo(
      brightness: json["brightness"] as int,
      volume: json["volume"] as int,
      power: json["power"] as String,
      battery: json["battery"] as int,
      wifi: json["wifi"] as bool,  // Now correctly handled as bool
      bluetooth: json["bluetooth"] as bool,  // Now correctly handled as bool
    );
  }

  // Create an instance from JSON string
  factory StatusInfo.fromJsonString(String jsonString) =>
      StatusInfo.fromJson(jsonDecode(jsonString));
}
