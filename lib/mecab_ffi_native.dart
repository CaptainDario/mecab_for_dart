import 'dart:ffi';
import 'package:ffi/ffi.dart';

// The Dart VM automatically resolves these @Native annotations to the 
// binary compiled by your build.dart hook. No dlopen() required!
@Native<Pointer<Void> Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>)>()
external Pointer<Void> initMecab(Pointer<Utf8> opt, Pointer<Utf8> dicdir, Pointer<Utf8> libpath);

@Native<Void Function(Pointer<Void>)>()
external void destroyMecab(Pointer<Void> tagger);

@Native<Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>)>()
external Pointer<Utf8> parse(Pointer<Void> tagger, Pointer<Utf8> input);

@Native<Int32 Function(Int32, Int32)>(symbol: 'native_add')
external int nativeAdd(int x, int y);

class MecabDartFfi {
  // Initialization is a no-op because Native Assets handles linking automatically!
  Future<void> init({String? libmecabPath, dynamic mecabFfiHelper}) async {} 

  Pointer<Void> initMecabFfi(Pointer<Utf8> opt, Pointer<Utf8> dicdir, Pointer<Utf8> libpath) => initMecab(opt, dicdir, libpath);
  void destroyMecabFfi(Pointer<Void> tagger) => destroyMecab(tagger);
  Pointer<Utf8> parseFfi(Pointer<Void> tagger, Pointer<Utf8> input) => parse(tagger, input);
  int nativeAddFunc(int x, int y) => nativeAdd(x, y);

  // Expose the standard package:ffi 'using' method so mecab_dart.dart can use it seamlessly
  void safeUsing(void Function(Arena) callback) {
    using(callback);
  }

  // Helper methods to handle string conversion internally, so mecab_dart.dart
  // doesn't have to deal with it
  Pointer<Void> initMecabString(String opt, String dicdir, String? libpath) {
    return using((Arena arena) {
      final optionsPtr = opt.toNativeUtf8(allocator: arena);
      final dictDirPtr = dicdir.toNativeUtf8(allocator: arena);
      final libPathPtr = libpath != null ? libpath.toNativeUtf8(allocator: arena) : nullptr;
      return initMecab(optionsPtr, dictDirPtr, libPathPtr);
    });
  }

  // Helper methods to handle string conversion internally, so mecab_dart.dart
  // doesn't have to deal with it
  String parseString(Pointer<Void> tagger, String input) {
    return using((Arena arena) {
      return parse(tagger, input.toNativeUtf8(allocator: arena)).toDartString();
    });
  }
}