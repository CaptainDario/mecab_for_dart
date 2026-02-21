// Package imports:
import 'package:universal_ffi/ffi.dart';
import 'package:universal_ffi/ffi_helper.dart';
import 'package:universal_ffi/ffi_utils.dart';

// --- Typedefs ---

// Init (Returns Tagger)
typedef InitMecabFuncC = Pointer<Void> Function(Pointer<Utf8> opt, Pointer<Utf8> dicdir, Pointer<Utf8> libpath);
typedef InitMecabFuncDart = Pointer<Void> Function(Pointer<Utf8> opt, Pointer<Utf8> dicdir, Pointer<Utf8> libpath);

// Destroy (Takes Tagger)
typedef DestroyMecabFuncC = Void Function(Pointer<Void> tagger);
typedef DestroyMecabFuncDart = void Function(Pointer<Void> tagger);

// Parse
typedef ParseFuncC = Pointer<Utf8> Function(Pointer<Void> tagger, Pointer<Utf8> input);
typedef ParseFuncDart = Pointer<Utf8> Function(Pointer<Void> tagger, Pointer<Utf8> input);

// Test
typedef NativeAddFuncC = Int32 Function(Int32 x, Int32 y);
typedef NativeAddFuncDart = int Function(int x, int y);


/// Class that contains all Mecab FFi references
class MecabDartFfi {

  late final FfiHelper mecabDartFfiHelper;

  late final InitMecabFuncDart initMecabFfi;
  late final DestroyMecabFuncDart destroyMecabFfi;
  late final ParseFuncDart parseFfi;
  late final NativeAddFuncDart nativeAddFunc;


  /// Initializes the communication to ffi
  Future<void> init({String? libmecabPath, FfiHelper? mecabFfiHelper}) async {

    if (libmecabPath == null && mecabFfiHelper == null) {
      throw ArgumentError("Not **both** `libmecabPath` and `mecabFfiHelper` can be null!");
    }

    if (mecabFfiHelper != null) {
      mecabDartFfiHelper = mecabFfiHelper;
    }
    else if (libmecabPath != null) {
      mecabDartFfiHelper = await FfiHelper.load(libmecabPath);
    }

    // Lookup functions
    initMecabFfi = mecabDartFfiHelper.library
      .lookup<NativeFunction<InitMecabFuncC>>('initMecab')
      .asFunction<InitMecabFuncDart>();
      
    destroyMecabFfi = mecabDartFfiHelper.library
      .lookup<NativeFunction<DestroyMecabFuncC>>('destroyMecab')
      .asFunction<DestroyMecabFuncDart>();

    parseFfi = mecabDartFfiHelper.library
      .lookup<NativeFunction<ParseFuncC>>('parse')
      .asFunction<ParseFuncDart>();

    nativeAddFunc = mecabDartFfiHelper.library
      .lookup<NativeFunction<NativeAddFuncC>>('native_add')
      .asFunction<NativeAddFuncDart>();
  }

  // Helper methods to handle string conversion internally, so mecab_dart.dart
  // doesn't have to deal with it
  Pointer<Void> initMecabString(String opt, String dicdir, String? libpath) {
    Pointer<Void> result = nullptr;
    mecabDartFfiHelper.safeUsing((arena) {
      final optionsPtr = opt.toNativeUtf8(allocator: arena);
      final dictDirPtr = dicdir.toNativeUtf8(allocator: arena);
      final libPathPtr = libpath != null ? libpath.toNativeUtf8(allocator: arena) : nullptr;
      result = initMecabFfi(optionsPtr, dictDirPtr, libPathPtr);
    });
    return result;
  }

  // Helper methods to handle string conversion internally, so mecab_dart.dart
  // doesn't have to deal with it
  String parseString(Pointer<Void> tagger, String input) {
    String result = "";
    mecabDartFfiHelper.safeUsing((arena) {
      result = parseFfi(tagger, input.toNativeUtf8(allocator: arena)).toDartString();
    });
    return result;
  }
}