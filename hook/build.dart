import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:native_toolchain_c/src/cbuilder/run_cbuilder.dart';
import 'package:native_toolchain_c/src/native_toolchain/android_ndk.dart';

void main(List<String> args) async {
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

    await builder.run(input: input, output: output);

    // Only run the workaround for Android targets
    if (input.config.code.targetOS == OS.android) {
      await _bundleAndroidStdLib(input, output);
    }
  });
}

/// Workaround for https://github.com/dart-lang/native/issues/2099
/// Manually finds and bundles 'libc++_shared.so' from the Android NDK.
Future<void> _bundleAndroidStdLib(BuildInput input, BuildOutputBuilder output) async {
  final targetArchitecture = input.config.code.targetArchitecture;
  
  final aclang = await androidNdkClang.defaultResolver!.resolve(
    logger: Logger(''),
  );

  for (final tool in aclang) {
    if (tool.tool.name == 'Clang') {
      final sysroot = tool.uri.resolve('../sysroot/').toFilePath();
      final androidArch = RunCBuilder.androidNdkClangTargetFlags[targetArchitecture];
      final libPath = '$sysroot/usr/lib/$androidArch/libc++_shared.so';

      output.assets.code.add(
        CodeAsset(
          package: input.packageName,
          name: 'libc++_shared.so',
          file: Uri.file(libPath),
          linkMode: DynamicLoadingBundled(),
        ),
      );
      break;
    }
  }
}