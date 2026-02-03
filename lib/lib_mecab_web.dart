// Dart imports:
import 'dart:async';

// Package imports:
import 'package:universal_ffi/ffi_helper.dart';



/// Loades the mecab dynamic library
Future<FfiHelper> loadMecabDartLib () async {

  return (await FfiHelper.load("assets/blobs/libmecab.js"));

}

