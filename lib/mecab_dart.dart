export 'token_node.dart';
export 'mecab_transferable_state.dart';

// Package imports:
import 'package:mecab_for_dart/lib_mecab.dart';
import 'package:mecab_for_dart/mecab_transferable_state.dart';
import 'package:universal_ffi/ffi.dart';
import 'package:universal_ffi/ffi_utils.dart' as ffi;

// Project imports:
import 'mecab_ffi.dart';
import 'token_node.dart';

/// Class that represents a Mecab Tagger instance
class Mecab {

  /// Pointer to the Mecab instance on the C side
  late final MecabDartFfi _mecabDartFfi;

  Pointer<Void>? _mecabPtr;

  /// Path to the Mecab dynamic library used
  late final String? libmecabPath;
  /// Path to the Mecab dictionary directory used
  late final String mecabDictDirPath;
  /// Whether to include token features in the output
  late final String options;

  MecabTransferableState get transferableState => MecabTransferableState(
    libmecabPath: libmecabPath,
    mecabDictDirPath: mecabDictDirPath,
    options: options,
  );

  Mecab._internal();

  /// Initializes this mecab instance,
  /// `libmecabPath` should be the path to a mecab dynamic library
  ///                Note: when using this package in Flutter, this parameter
  ///                can be null, and the library will be loaded from the 
  ///                package's compiled mecab dynamic library.
  /// `dictDir` should be a directory that contains a Mecab dictionary
  /// (ex. IpaDic) 
  /// `options` can be used 
  static Future<Mecab> create(
    String? libmecabPath,
    String dictDir,
    String options
  ) async {
  
    final instance = Mecab._internal();

    instance._mecabDartFfi = MecabDartFfi();
    
    if(libmecabPath != null) {
      await instance._mecabDartFfi.init(libmecabPath: libmecabPath);
    }
    else {
      await instance._mecabDartFfi.init(mecabFfiHelper: await loadMecabDartLib());
    }

    instance._mecabDartFfi.mecabDartFfiHelper.safeUsing((ffi.Arena arena) {
      final optionsPtr = options.toNativeUtf8(allocator: arena);
      final dictDirPtr = dictDir.toNativeUtf8(allocator: arena);
      final libPathPtr = libmecabPath != null 
        ? libmecabPath.toNativeUtf8(allocator: arena) 
        : nullptr;

      instance._mecabPtr = instance._mecabDartFfi.initMecabFfi(
        optionsPtr, dictDirPtr, libPathPtr);
    });

    // Check if initialization failed
    try {
      instance._mecabDartFfi.nativeAddFunc(1, 2);
    }
    catch (e) {
      throw Exception("Failed to initialize Mecab. Check your dictionary path: '$dictDir' and library path: '$libmecabPath'. Error details: $e");
    }

    instance.libmecabPath = libmecabPath;
    instance.mecabDictDirPath = dictDir;
    instance.options = options;

    return instance;
  }

  /// Parses the given text using mecab and returns the raw string output.
  String rawParse(String input) {
    if (_mecabPtr == null || _mecabPtr!.address == 0) {
      throw Exception("Mecab instance is disposed or invalid.");
    }

    var resultStr = "";

    // safeUsing handles the freeing of the input string pointer
    _mecabDartFfi.mecabDartFfiHelper.safeUsing((ffi.Arena arena) {
      resultStr =
        (_mecabDartFfi.parseFfi(_mecabPtr!, input.toNativeUtf8(allocator: arena)))
        .toDartString().trim();
    });

    return resultStr;
  }

  /// Parses the given text using mecab and returns parsed [TokenNode]s
  /// 
  /// Note: This method may fail if you use certain `options`. In that case, use
  /// `rawParse` instead, which returns the raw string output from mecab, and
  /// parse it manually.
  List<TokenNode> parse(String input) {

    String rawOutput = rawParse(input);

    List<String> items;
    if (rawOutput.contains('\n')) {
      items = rawOutput.split('\n');
    }
    else {
      items = rawOutput.split(' ');
    }

    List<TokenNode> tokens = [];
    for (var item in items) {
      if (item.isNotEmpty) {
        tokens.add(TokenNode(item));
      }
    }
    return tokens;

  }

  void dispose() {
    if (_mecabPtr != null && _mecabPtr!.address != 0) {
      _mecabDartFfi.destroyMecabFfi(_mecabPtr!);
      _mecabPtr = null;
    }
  }

  static Future<Mecab> fromTransferableState(MecabTransferableState state) async {
    return await Mecab.create(
      state.libmecabPath, state.mecabDictDirPath, state.options);
  }

}