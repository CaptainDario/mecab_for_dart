import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> args) async {
  // 1. Changed 'config' to 'input' in the callback parameters
  await build(args, (input, output) async {
    final builder = CBuilder.library(
      name: 'mecab_dart',
      assetName: 'mecab_ffi_native.dart', 
      language: Language.cpp,
      flags: ['-std=c++11'],
      sources: [
        'src/char_property.cpp',
        'src/eval.cpp',
        'src/nbest_generator.cpp',
        'src/tokenizer.cpp',
        'src/connector.cpp',
        'src/iconv_utils.cpp',
        'src/param.cpp',
        'src/utils.cpp',
        'src/context_id.cpp',
        'src/libmecab.cpp',
        'src/string_buffer.cpp',
        'src/viterbi.cpp',
        'src/dictionary.cpp',
        'src/dart_ffi.cpp',
        'src/tagger.cpp',
        'src/writer.cpp',
      ],
    );
    
    // 2. Pass 'input: input' instead of 'config: config'
    await builder.run(input: input, output: output);
  });
}