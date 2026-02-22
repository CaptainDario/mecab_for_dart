import 'dart:convert';

class MecabTransferableState {
  final String webLibMecabPath;
  final String mecabDictDirPath;
  final String options;

  MecabTransferableState({
    required this.webLibMecabPath,
    required this.mecabDictDirPath,
    required this.options,
  });

  Map<String, dynamic> toJson() => {
    "libmecabPath": webLibMecabPath,
    "mecabDictDirPath": mecabDictDirPath,
    "options": options,
  };

  String toJsonString() => jsonEncode(toJson());

  factory MecabTransferableState.fromJson(Map<String, dynamic> json) {
    return MecabTransferableState(
      webLibMecabPath: json["libmecabPath"],
      mecabDictDirPath: json["mecabDictDirPath"],
      options: json["options"],
    );
  }

  factory MecabTransferableState.fromJsonString(String jsonString) {
    return MecabTransferableState.fromJson(jsonDecode(jsonString));
  }
}