// Dart imports:
import 'dart:async';
import 'dart:ffi';

// Package imports:
import 'package:universal_ffi/ffi_helper.dart';
import 'package:universal_io/io.dart';



/// Loades the mecab dynamic library
Future<FfiHelper> loadMecabDartLib () async {

  FfiHelper ffiHelper;

  if(Platform.isAndroid){
    // 'lib' is automatically added to the library name
    ffiHelper = (await FfiHelper.load("mecab_dart.so", options: {LoadOption.isFfiPlugin}));
  }
  else if(Platform.isWindows) {
    String architecture = () {
      if(Abi.current() == Abi.windowsArm64){
        return "arm64";
      }
      else if(Abi.current() == Abi.windowsX64){
        return "x86";
      }
      else{
        throw Exception("This platform is not supported by mecab_for_flutter!");
      }
    } ();
    ffiHelper = (await FfiHelper.load(
      "libmecab_${architecture}.dll"
    ));
  }
  else {
    ffiHelper = (await FfiHelper.load("",
      options: {LoadOption.isStaticallyLinked, LoadOption.isFfiPlugin}));
  }

  return ffiHelper;

}

