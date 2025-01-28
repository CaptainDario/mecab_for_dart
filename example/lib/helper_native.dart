import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:universal_io/io.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';



/// Returns the path to mecab dictionary
Future<String> getDictDir(String dictPath, String? package) async {

  // get paht to documents folders and create ipadic folder
  final Directory ipaDicDir = Directory(p.joinAll([
    (await getApplicationDocumentsDirectory()).path, dictPath
  ]));
  if(!ipaDicDir.existsSync()){
    ipaDicDir.createSync(recursive: true);
  }

  // copy assets if they do not already exist
  /// List of file names that are used in a mecab dictionary
  List<String> mecabDictFiles = [
    'char.bin', 'dicrc', 'left-id.def', 'matrix.bin', 'pos-id.def',
    'rewrite.def', 'right-id.def', 'sys.dic', 'unk.dic', 'mecabrc'
  ];
  for (var mecabDictFile in mecabDictFiles) {
    await copyFileFromAssets(
      p.joinAll([dictPath, mecabDictFile]),
      p.joinAll([ipaDicDir.path, mecabDictFile]));
  }

  return ipaDicDir.absolute.path;

}

/// Copies `assetFile` to `destinatioFile` if it does not already
/// exist
Future<void> copyFileFromAssets(String assetFile, String destination) async 
{
  if (FileSystemEntity.typeSync(destination) == FileSystemEntityType.notFound) {
    ByteData data = (await rootBundle.load(assetFile));
    ByteBuffer buffer = data.buffer;
    Uint8List bytes = buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    File(destination).writeAsBytesSync(bytes);
  }
}
