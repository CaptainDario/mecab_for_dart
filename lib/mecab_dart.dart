export 'token_node.dart';
export 'mecab_transferable_state.dart';

// Package imports:
import 'package:mecab_for_dart/mecab_transferable_state.dart';

// Project imports:
import 'mecab_ffi.dart';
import 'token_node.dart';



/// Class that represents a Mecab Tagger instance
class Mecab {

  /// Pointer to the Mecab instance on the C side
  late final MecabDartFfi _mecabDartFfi;

  // We use dynamic here because dart:ffi Pointer<Void> and 
  // universal_ffi Pointer<Void> are technically different types to the analyzer.
  dynamic _mecabPtr;

  /// Path to the Mecab dynamic library used
  late final String? weblibmecabPath;
  /// Path to the Mecab dictionary directory used
  late final String mecabDictDirPath;
  /// Whether to include token features in the output
  late final String options;

  MecabTransferableState get transferableState => MecabTransferableState(
    libmecabPath: weblibmecabPath,
    mecabDictDirPath: mecabDictDirPath,
    options: options,
  );

  Mecab._internal();

  /// Initializes this mecab instance,
  /// `dictDir` should be a directory that contains a Mecab dictionary
  ///           (ex. IpaDic) 
  /// `options` can be used 
  /// `libmecabPath` only used on web, sets the path where the Mecab WASM binary
  ///                is located.
  static Future<Mecab> create({
    required String dictDir,
    String options = "",
    String? webLibmecabPath,
    
  }) async {
  
    final instance = Mecab._internal();
    instance._mecabDartFfi = MecabDartFfi();
    
    // Delegate ALL initialization logic to the FFI classes.
    // On Native: This does nothing (Native Assets links it automatically).
    // On Web: The web FFI class internally calls loadMecabDartLib().
    await instance._mecabDartFfi.init(libmecabPath: webLibmecabPath);

    // Initialize the C++ pointer
    instance._mecabPtr = instance._mecabDartFfi.initMecabString(options, dictDir, webLibmecabPath);

    // Check if initialization failed
    try {
      instance._mecabDartFfi.nativeAddFunc(1, 2);
    }
    catch (e) {
      throw Exception("Failed to initialize Mecab. Check your dictionary path: '$dictDir' and library path: '$webLibmecabPath'. Error details: $e");
    }

    instance.weblibmecabPath = webLibmecabPath;
    instance.mecabDictDirPath = dictDir;
    instance.options = options;

    return instance;
  }

  /// Parses the given text using mecab and returns the raw string output.
  String rawParse(String input) {
    if (_mecabPtr == null) 
      throw Exception("Mecab instance is disposed or invalid.");

    return _mecabDartFfi.parseString(_mecabPtr, input).trim();
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
    if (_mecabPtr != null) {
      _mecabDartFfi.destroyMecabFfi(_mecabPtr);
      _mecabPtr = null;
    }
  }

  static Future<Mecab> fromTransferableState(MecabTransferableState state) async {
    return await Mecab.create(
      dictDir: state.mecabDictDirPath,
      options: state.options,
      webLibmecabPath: state.libmecabPath,
    );
  }

}