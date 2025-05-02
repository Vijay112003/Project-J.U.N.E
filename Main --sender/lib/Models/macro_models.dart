
class MacroModel {
  final String macroName;
  final String description;
  final String macroPath;

  MacroModel({
    required this.macroName,
    required this.description,
    required this.macroPath,
  });

  factory MacroModel.fromJson(Map<String, dynamic> json) {
    return MacroModel(
      macroName: json['name'] as String,
      description: json['description'] as String,
      macroPath: json['json_path'] as String, // ✅ Corrected key
    );
  }

  @override
  String toString() {
    return 'MacroModel(name: $macroName, description: $description, macroPath: $macroPath)';
  }
}