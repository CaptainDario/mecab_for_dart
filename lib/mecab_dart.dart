export 'token_node.dart';

// Package imports:
import 'package:universal_ffi/ffi_utils.dart' as ffi;

// Project imports:
import 'mecab_ffi.dart';
import 'token_node.dart';

/// Class that represents a Mecab instance
class Mecab {


  /// Pointer to the Mecab instance on the C side
  late final MecabDartFfi mecabDartFfi;


  /// Initializes this mecab instance,
  /// `libmecabPath` should be the path to a mecab dynamic library
  /// `dictDir` should be a directory that contains a Mecab dictionary
  /// (ex. IpaDic) 
  /// If `includeFeatures` is set, the output of mecab includes the
  /// token-features.
  /// 
  /// Warning: This method needs to be called before any other method
  Future<void> init(String libmecabPath, String dictDir, bool includeFeatures) async {
  
    var options = includeFeatures ? "" : "-Owakati";
    mecabDartFfi = MecabDartFfi();
    await mecabDartFfi.init(libmecabPath: libmecabPath);

    mecabDartFfi.mecabDartFfiHelper.safeUsing((ffi.Arena arena) {
      mecabDartFfi.mecabPtr = mecabDartFfi.initMecabFfi(
        options.toNativeUtf8(), dictDir.toNativeUtf8());
    });
    
  }

  /// Parses the given text using mecab and returns mecab's output
  List<TokenNode> parse(String input) {

    var resultStr = "";

    resultStr =
      (mecabDartFfi.parseFfi(mecabDartFfi.mecabPtr!, input.toNativeUtf8()))
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
    if (mecabDartFfi.mecabPtr != null) {
      mecabDartFfi.destroyMecabFfi(mecabDartFfi.mecabPtr!);
    }
  }

}
