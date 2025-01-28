# mecab_for_dart

MeCab (Japanese Morphological Analyzer) bindings for standalone dart.
The Flutter version of this package can be found [here](https://pub.dev/packages/mecab_for_flutter)
[Try it out using flutter in the browser!](https://captaindario.github.io/mecab_for_dart/).

| Android | iOS | Windows | MacOS | Linux | Web | Web --wasm |
|:-------:|:---:|:-------:|:-----:|:-----:|:---:|:----------:|
|    ✅    |  ✅  |    ✅    |   ✅   |   ✅   |  ✅  |      [❌](https://github.com/CaptainDario/mecab_for_dart/issues/5)     |

## Installation

1. Add this plug_in as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).
```yaml
dependencies:   
   mecab_for_dart: <your_version> 
```

## Getting the binaries

Pre-compiled binaries are provided for Linux (x86/arm64), Macos (x86/arm64) and Windows (x86/arm64), you can download them [here](https://github.com/CaptainDario/mecab_for_dart/releases/tag/data).
Download the one you need and place them somwhere your data application can access them, in this README that path will be donated by <LIB_MECAB_PATH>

## Getting a dictionary

Any dictionary that is compatible with mecab will work, but for ease of getting started, a copy of ipadic and unidic is provided [here](https://github.com/CaptainDario/mecab_for_dart/releases/tag/data).
Download the one you need and place them somwhere your data application can access them, in this README that path will be donated by <DICT_MECAB_PATH>

## Example

Init Mecab:

```dart
var tagger = new Mecab();
await tagger.init("<LIB_MECAB_PATH>", "<DICT_MECAB_PATH>", true);
```

Set the boolean option in `init` function to true if you want to get the tokens including features,
set it to false if you only want the token surfaces.

Use the tagger to parse text:

```dart
var tokens = tagger.parse('にわにわにわにわとりがいる。');
var text = '';

for(var token in tokens) {
  text += token.surface + "\t";
  for(var i = 0; i < token.features.length; i++) {
    text += token.features[i];
    if(i + 1 < token.features.length) {
       text += ",";
    }
  }
  text += "\n";
}
```

### Notes for web usage

This library tries to load the mecab dictionary from the WASM filesystem.
The easiest way to get the dictionary in it, is by bundling it when compiling mecab to wasm.
However, it may be desirable to swap dictionaries. To do this, you need to load the dictionary into libmecab's wasm memory.

## Building the binaries

### Linux

TODO

### MacOS

```bash
cd macos/Classes/
make libmecab
```

### Windows

Because mecab uses nmake on windows to compile, the mecab DLL needs to be created separately.
For this open a [**Developer Command Prompt**](https://learn.microsoft.com/en-us/visualstudio/ide/reference/command-prompt-powershell?view=vs-2022) and change in the `windows/src` directory.
In this directory execute `nmake -f  Makefile.x64.msvc` (compile on x86) or `nmake -f  Makefile.arm64.msvc` (compile on arm64).
After the build process finished, there should be a `libmecab.dll` in `windows/src`.

### Android / iOS

As dart is not really available for running on iOS / Android there are no precompiled binaries or build scripts available.
If you see a need for this please open an issue or PR!

### Web

On web this plugin uses WASM.

To compile for WASM this project uses [Emscripten](https://emscripten.org/).
Therefore, to compile a wasm binary, first emscripten needs to be installed.
Then, a WASM binary can be compiled by running `compile_wasm_bare.sh` (no dictionary included) or `compile_wasm_embed.sh` (ipadic embedded).
This will generate `libmecab.js` and `libmecab.wasm` in the folder `emcc_out/`.
Those files then need to be loaded by your application.
For more details, see the example.
