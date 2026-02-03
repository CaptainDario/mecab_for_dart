export 'lib_mecab_stub.dart'
  if (dart.library.io) 'lib_mecab_native.dart'
  if (dart.library.js_interop) 'lib_mecab_web.dart';   