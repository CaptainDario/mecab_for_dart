export 'token_node.dart';
export 'mecab_transferable_state.dart';

// Package imports:
import 'package:mecab_for_dart/lib_mecab.dart';
import 'package:mecab_for_dart/mecab_transferable_state.dart';
import 'package:universal_ffi/ffi_utils.dart' as ffi;

// Project imports:
import 'mecab_ffi.dart';
import 'token_node.dart';

/// Class that represents a Mecab instance
class Mecab {


  /// Pointer to the Mecab instance on the C side
  late final MecabDartFfi _mecabDartFfi;
  /// Path to the Mecab dynamic library used
  late final String? libmecabPath;
  /// Path to the Mecab dictionary directory used
  late final String mecabDictDirPath;
  /// Whether to include token features in the output
  late final bool includeFeatures;

  MecabTransferableState get transferableState => MecabTransferableState(
    libmecabPath: libmecabPath,
    mecabDictDirPath: mecabDictDirPath,
    includeFeatures: includeFeatures,
  );

  Mecab();

  /// Initializes this mecab instance,
  /// `libmecabPath` should be the path to a mecab dynamic library
  ///                Note: when using this package in Flutter, this parameter
  ///                can be null, and the library will be loaded from the 
  ///                package's compiled mecab dynamic library.
  /// `dictDir` should be a directory that contains a Mecab dictionary
  /// (ex. IpaDic) 
  /// If `includeFeatures` is set, the output of mecab includes the
  /// token-features.
  /// 
  /// Warning: This method needs to be called before any other method
  Future<void> init(String? libmecabPath, String dictDir, bool includeFeatures) async {
  
    var options = includeFeatures ? "" : "-Owakati";
    _mecabDartFfi = MecabDartFfi();
    
    if(libmecabPath != null){
      await _mecabDartFfi.init(libmecabPath: libmecabPath);
    }
    else{
      await _mecabDartFfi.init(mecabFfiHelper: await loadMecabDartLib());
    }

    _mecabDartFfi.mecabDartFfiHelper.safeUsing((ffi.Arena arena) {
      _mecabDartFfi.mecabPtr = _mecabDartFfi.initMecabFfi(
        options.toNativeUtf8(), dictDir.toNativeUtf8());
    });

    this.libmecabPath = libmecabPath;
    this.mecabDictDirPath = dictDir;
    this.includeFeatures = includeFeatures;
    
  }

  /// Parses the given text using mecab and returns mecab's output
  List<TokenNode> parse(String input) {

    var resultStr = "";

    resultStr =
      (_mecabDartFfi.parseFfi(_mecabDartFfi.mecabPtr!, input.toNativeUtf8()))
      .toDartString().trim();

    List<String> items;
    if (resultStr.contains('\n')) {
      items = resultStr.split('\n');
    } else {
      items = resultStr.split(' ');
    }

    List<TokenNode> tokens = [];
    for (var item in items) {
      tokens.add(TokenNode(item));
    }
    return tokens;

  }

  /// Frees the memory used by mecab and 
  void destroy() {
    if (_mecabDartFfi.mecabPtr != null) {
      _mecabDartFfi.destroyMecabFfi(_mecabDartFfi.mecabPtr!);
    }
  }

  Future<Mecab> fromTransferableState(MecabTransferableState state) async {
    final m = Mecab();
    m.init(
      state.libmecabPath,
      state.mecabDictDirPath,
      state.includeFeatures,
    );

    return m;
  }

}

