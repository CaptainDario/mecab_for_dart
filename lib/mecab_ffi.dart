export 'mecab_ffi_web.dart' // Default to web/stub
  if (dart.library.io) 'mecab_ffi_native.dart'
  if (dart.library.js_interop) 'mecab_ffi_web.dart';