# mecab_for_dart

MeCab (Japanese Morphological Analyzer) bindings for standalone dart.

[Try it out using flutter in the browser!](https://captaindario.github.io/mecab_for_flutter/).

| Android | iOS | Windows | MacOS | Linux | Web | Web --wasm |
|:-------:|:---:|:-------:|:-----:|:-----:|:---:|:----------:|
|    ✅    |  ✅  |    ✅    |   ✅   |   ✅   |  ✅  |      [❌](https://github.com/CaptainDario/mecab_for_dart/issues/5)     |


## Installation

1. Add this plug in as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

```yaml
dependencies:   
   mecab_for_dart: <your_version> 
```

### Getting a dictionary

Any dictionary that is compatible with MeCab will work, but for ease of getting started, a copy of `ipadic` and `unidic` [can be downloaded in the release section of this repo](https://github.com/CaptainDario/mecab_for_dart/releases/) (if you use your own, you need to assure that the dictionary has `mecabrc` file).
Download the one you need and place them somewhere your dart application can access them, in this README that path will be donated by `<DICT_MECAB_PATH>`

## Usage

Init Mecab:

```dart
var tagger = await Mecab.create(
  dictDir: "<DICT_MECAB_PATH>", // the path to you dictionary
  options: "<YOUR_MECAB_OPTIONS>", // options you want mecab to use, ex.: "-Owakati"
  webLibmecabPath: "<LIB_MECAB_PATH>" // path where your wasm files are
);
```

Then use the tagger to parse text:

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

This library tries to load the MeCab dictionary from the WASM file system.
The easiest way to get the dictionary in it, is by bundling it when compiling MeCab to WASM.
However, it may be desirable to swap dictionaries. To do this, you need to load the dictionary into libmecab's WASM memory.

### Isolate usage

This library is safe to use across isolates, but the `Mecab` class itself cannot be passed across isolates.
You need to send its state and then instantiate a new instance from that state.

```dart
// in the main isolate
final var state = mecab.transferableState;

// send the state to the isolate
// ...

// in the isolate
// ... receive the state
final Mecab m = await Mecab.fromTransferableState(state);
```

The native c++ code takes care of your differen mecab setups and only loads the heavy dictionary into memory once (per configuration).

### Mecab Options usage

You can pass any options when creating a new mecab instance.
But be aware that not every output format is supported by `parse()`, you may need to switch to `rawParse()` and then parse the string output yourself.

## Building binaries

<details>

<summary>Details...</summary>

If you desire to compile a mecab library you can do it like this:

### Linux

```bash
cd linux/
# this builds for the architecture you are on
make libmecab
```

### MacOS

```bash
cd macos/Classes/
make libmecab

# use rosetta on apple silicone to cross compile
arch -x86_64 make libmecab
```

### Windows

Because MeCab uses NMAKE on Windows to compile, the MeCab DLL needs to be created separately.
For this open a [**Developer Command Prompt**](https://learn.microsoft.com/en-us/visualstudio/ide/reference/command-prompt-powershell?view=vs-2022) and change in the `windows/src` directory.
In this directory execute `nmake -f  Makefile.x64.msvc` (compile on x86) or `nmake -f  Makefile.arm64.msvc` (compile on arm64).
After the build process finished, there should be a `libmecab.dll` in `windows/src`.

### Android / iOS

As dart (standalone!) is not really used for running on iOS / Android there are no precompiled binaries or build scripts available.
If you see a need for this please open an issue or PR!

### Web

On web this plugin uses WASM.

To compile for WASM this project uses [Emscripten](https://emscripten.org/).
Therefore, to compile a WASM binary, first Emscripten needs to be installed.
Then, a WASM binary can be compiled by running `compile_wasm_bare.sh` (no dictionary included) or `compile_wasm_embed.sh` (ipadic embedded, can be changed using `--embed-file`).
This will generate `libmecab.js` and `libmecab.wasm` in the folder `emcc_out/`.
Those files then need to be loaded by your application.
For more details, see the example in the Flutter package.

</details>
