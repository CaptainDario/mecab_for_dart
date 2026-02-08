import 'dart:convert';

class MecabTransferableState {
  final String? libmecabPath;
  final String mecabDictDirPath;
  final String options;

  MecabTransferableState({
    this.libmecabPath,
    required this.mecabDictDirPath,
    required this.options,
  });

  Map<String, dynamic> toJson() => {
    "libmecabPath": libmecabPath,
    "mecabDictDirPath": mecabDictDirPath,
    "options": options,
  };

  String toJsonString() => jsonEncode(toJson());

  factory MecabTransferableState.fromJson(Map<String, dynamic> json) {
    return MecabTransferableState(
      libmecabPath: json["libmecabPath"],
      mecabDictDirPath: json["mecabDictDirPath"],
      options: json["options"],
    );
  }

  factory MecabTransferableState.fromJsonString(String jsonString) {
    return MecabTransferableState.fromJson(jsonDecode(jsonString));
  }
}