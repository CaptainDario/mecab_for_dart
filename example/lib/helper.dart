// Dart imports:
import 'dart:async';

// Package imports:
import 'package:universal_ffi/ffi_helper.dart';
import 'package:universal_io/io.dart';
import 'package:path/path.dart' as p;



/// Returns the path to mecab dictionary
Future<String> getDictDir(String dictPath, String? package) async {

  throw UnimplementedError("This is not implemented");

}

Future<FfiHelper> loadMecabDartLib () async {

  FfiHelper ffiHelper;

  if (const bool.fromEnvironment('dart.library.html')) {
    ffiHelper = (await FfiHelper.load("assets/blobs/libmecab.js"));
  }
  else if(Platform.isAndroid){
    // 'lib' is automatically added to the library name
    ffiHelper = (await FfiHelper.load("mecab_dart.so", options: {LoadOption.isFfiPlugin}));
  }
  else if(Platform.isWindows) {
    ffiHelper = (await FfiHelper.load(
      p.joinAll([
        Directory(Platform.resolvedExecutable).parent.path, "blobs", "libmecab.dll"
      ]),
    ));
  }
  else if(Platform.isMacOS) {
    ffiHelper = (await FfiHelper.load("/Users/darioklepoch/Library/Containers/com.example.example/Data/mecab.dylib"));
  }
  else {
    ffiHelper = (await FfiHelper.load("",
      options: {LoadOption.isStaticallyLinked, LoadOption.isFfiPlugin}));
  }

  return ffiHelper;

}