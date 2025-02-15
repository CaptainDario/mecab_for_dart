import 'package:mecab_for_dart/mecab_dart.dart';



void main() async {
  
  final tagger = Mecab();
  await tagger.init("mecab.dylib", "ipadic", true);

  final surfaces = tagger.parse("林檎を食べる").map((e) => e.surface,).toList();
  print(surfaces);

}