class MecabTransferableState {
  final String? libmecabPath;
  final String mecabDictDirPath;
  final bool includeFeatures;

  MecabTransferableState({
    this.libmecabPath,
    required this.mecabDictDirPath,
    required this.includeFeatures,
  });

  Map<String, dynamic> toJson() => {
    "libmecabPath": libmecabPath,
    "mecabDictDirPath": mecabDictDirPath,
    "includeFeatures": includeFeatures,
  };

  factory MecabTransferableState.fromJson(Map<String, dynamic> json) {
    return MecabTransferableState(
      libmecabPath: json["libmecabPath"],
      mecabDictDirPath: json["mecabDictDirPath"],
      includeFeatures: json["includeFeatures"],
    );
  }
}