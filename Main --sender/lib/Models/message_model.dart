class SendMessageModel {
  final String type;
  final String action;
  final String module;
  final String value;
  final String text;
  final String filepath;
  final String dx;
  final String dy;
  final String speed;

  // Constructor with optional parameters
  SendMessageModel({
    required this.type,
    this.action = "",
    this.module = "",
    this.value = "",
    this.text = "",
    this.filepath = "",
    this.dx = "",
    this.dy = "",
    this.speed = "",
  });

  // Convert the object to JSON
  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "action": action,
      "module": module,
      "value": value,
      "text": text,
      "filepath": filepath,
      "dx": dx,
      "dy": dy,
      "speed": speed,
    };
  }
}
