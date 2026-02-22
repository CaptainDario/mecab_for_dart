import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:native_toolchain_c/src/cbuilder/run_cbuilder.dart';
import 'package:native_toolchain_c/src/native_toolchain/android_ndk.dart';

void main(List<String> args) async {

  await build(args, (input, output) async {

    // skip web (all unsupported OSs) as it is not supported by hooks
    try {
      // Accessing .code threw a Null Check on Web. 
      // If it throws, we catch it and skip the build safely.
      var _ = input.config.code.targetOS;
    }
    catch (_) {
      return; 
    }

    String platform = input.config.code.targetOS == OS.windows ? "windows" : "unix";

    final builder = CBuilder.library(
      name: 'mecab_dart',
      assetName: 'mecab_ffi_native.dart',
      language: Language.cpp,
      flags: [
        // set standard version
        if (input.config.code.targetOS == OS.windows) '/std:c++14'
        else '-std=c++11',
        // Add explicit exception handling for MSVC
        if (input.config.code.targetOS == OS.windows) ...[
          '/EHsc',
          '/O2',
          '/GL',
          '/GA',
          '/Ob2',
          '/W3',
          '/MT',
          '/Zi',
          '/wd4800',
          '/wd4305',
          '/wd4244',
        ]
      ],
      includes: ['src', 'src/$platform'],
      defines: {
        'HAVE_CONFIG_H': null,
      },
      sources: [
        'src/dart_ffi.cpp',
        'src/$platform/char_property.cpp',
        'src/$platform/eval.cpp',
        'src/$platform/nbest_generator.cpp',
        'src/$platform/tokenizer.cpp',
        'src/$platform/connector.cpp',
        'src/$platform/iconv_utils.cpp',
        'src/$platform/param.cpp',
        'src/$platform/utils.cpp',
        'src/$platform/context_id.cpp',
        'src/$platform/libmecab.cpp',
        'src/$platform/string_buffer.cpp',
        'src/$platform/viterbi.cpp',
        'src/$platform/dictionary.cpp',
        'src/$platform/tagger.cpp',
        'src/$platform/writer.cpp',
        if (input.config.code.targetOS == OS.windows) ...[
          'src/$platform/feature_index.cpp',
          'src/$platform/dictionary_rewriter.cpp',
          'src/$platform/dictionary_generator.cpp',
          'src/$platform/dictionary_compiler.cpp',
          'src/$platform/learner.cpp',
          'src/$platform/learner_tagger.cpp',
          'src/$platform/lbfgs.cpp',
        ]
      ],
    );

    await builder.run(
      input: input,
      output: output,
      logger: Logger('')
        ..level = Level.ALL
        ..onRecord.listen((record) => print(record.message)),
    );

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