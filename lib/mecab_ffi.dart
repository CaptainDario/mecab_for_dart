// Package imports:
import 'package:universal_ffi/ffi.dart';
import 'package:universal_ffi/ffi_helper.dart';
import 'package:universal_ffi/ffi_utils.dart';



typedef InitMecabFunc = Pointer<Void> Function(
  Pointer<Utf8> options, Pointer<Utf8> dicdir);
typedef ParseFunc = Pointer<Utf8> Function(
  Pointer<Void> m, Pointer<Utf8> input);
typedef DestroyMecabFunc = Void Function(Pointer<Void> mecab);
typedef DestroyMecabFuncC = void Function(Pointer<Void> mecab);
typedef NativeAddFunc = void Function(Pointer<Void> mecab);

/// Class that contains all Mecab FFi things
class MecabDartFfi {

  late final FfiHelper mecabDartFfiHelper;

  late final Pointer<Void>? mecabPtr;

  late final Pointer<NativeFunction<InitMecabFunc>> initMecabPointer;
  late final InitMecabFunc initMecabFfi;

  late final Pointer<NativeFunction<ParseFunc>> parsePointer;
  late final ParseFunc parseFfi;
  
  late final Pointer<NativeFunction<DestroyMecabFunc>> destroyMecabPointer;
  late final DestroyMecabFuncC destroyMecabFfi;

  late final int Function(int x, int y) nativeAddFunc;


  /// Initializes the communication to ffi
  Future<void> init(String libmecabPath) async {

    mecabDartFfiHelper = await FfiHelper.load(libmecabPath);

    initMecabPointer = mecabDartFfiHelper.library
      .lookup<NativeFunction<InitMecabFunc>>('initMecab');
    initMecabFfi = initMecabPointer.asFunction<InitMecabFunc>();

    parsePointer = mecabDartFfiHelper.library
      .lookup<NativeFunction<ParseFunc>>('parse');
    parseFfi = parsePointer.asFunction<ParseFunc>();

    destroyMecabPointer = mecabDartFfiHelper.library
      .lookup<NativeFunction<DestroyMecabFunc>>('destroyMecab');
    destroyMecabFfi = destroyMecabPointer.asFunction<DestroyMecabFuncC>();

    nativeAddFunc = mecabDartFfiHelper.library
      .lookup<NativeFunction<Int32 Function(Int32, Int32)>>('native_add')
      .asFunction();

  }

}



