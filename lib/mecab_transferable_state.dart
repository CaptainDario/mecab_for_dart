import 'dart:convert';

import 'package:mecab_for_dart/globals.dart';

class MecabTransferableState {
  final String mecabDictDirPath;
  final String options;
  final String webLibMecabPath;

  MecabTransferableState({
    required this.mecabDictDirPath,
    this.options = defaultOptions,
    this.webLibMecabPath = defaultWebLibMecabPath,
  });

  Map<String, dynamic> toJson() => {
    "mecabDictDirPath": mecabDictDirPath,
    "options": options,
    "webLibMecabPath": webLibMecabPath,
  };

  String toJsonString() => jsonEncode(toJson());

  factory MecabTransferableState.fromJson(Map<String, dynamic> json) {
    return MecabTransferableState(
      mecabDictDirPath: json["mecabDictDirPath"],
      options: json["options"],
      webLibMecabPath: json["webLibMecabPath"],
    );
  }

  factory MecabTransferableState.fromJsonString(String jsonString) {
    return MecabTransferableState.fromJson(jsonDecode(jsonString));
  }
}