
class SendMessageModel {
  final String type;
  final String action;
  final String module;
  final String value;
  final String text;
  final String filepath;

  // Constructor to initialize the object with values
  SendMessageModel({
    required this.type,
    this.action = "",
    this.module = "",
    this.value = "",
    this.text = "",
    this.filepath = "",
  });

  // Convert a MessageModel object into a JSON object
  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "action": action,
      "module": module,
      "value": value,
      "text": text,
      "filepath": filepath,
    };
  }
}
