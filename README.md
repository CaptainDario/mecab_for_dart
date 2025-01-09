# mecab_for_dart

MeCab(Japanese Morphological Analyzer) bindings for dart (standalone dart and flutter!) on all platforms.
[Try it out in the browser](https://captaindario.github.io/mecab_for_dart/).

| Android | iOS | Windows | MacOS | Linux | Web | Web --wasm |
|:-------:|:---:|:-------:|:-----:|:-----:|:---:|:----------:|
|    ✅    |  ✅  |    ✅    |   ✅   |   ✅   |  ✅  |      [❌](https://github.com/CaptainDario/mecab_for_dart/issues/5)     |

## Installation

1. Add this plug_in as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).
```yaml
dependencies:   
   mecab_for_dart: <your_version> 
```

<details>
<summary>Windows only setup</summary>
Create a `blobs` folder on the top level of your application and copy the dll's from `example/blobs` there.
Lastly, open `windows/CMakeLists.txt` of your application and append at the end:

``` CMake
# Include the mecab binary
message(STATUS "Detected processor architecture: ${CMAKE_SYSTEM_PROCESSOR}")
if(CMAKE_SYSTEM_PROCESSOR STREQUAL "ARM64")
    set(MECAB_DLL ${PROJECT_BUILD_DIR}/../blobs/libmecab_arm64.dll)
elseif(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
    set(MECAB_DLL ${PROJECT_BUILD_DIR}/../blobs/libmecab_x86.dll)
endif()

install(
  FILES
    ${MECAB_DLL}
  DESTINATION
    ${INSTALL_BUNDLE_DATA_DIR}/../blobs/
  RENAME
    libmecab.dll
)
```
</details>

## Example

Init Mecab:

```dart
var tagger = new Mecab();
await tagger.init("path/to/your/dictionary/", true);
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

### Web

On web this plugin uses WASM.

To compile for WASM this project uses [Emscripten](https://emscripten.org/).
Therefore, to compile a wasm binary, first emscripten needs to be installed.
Then, a WASM binary can be compiled by running `compile_wasm_bare.sh` (no dictionary included) or `compile_wasm_embed.sh` (ipadic embedded).
This will generate `libmecab.js` and `libmecab.wasm` in the folder `emcc_out/`.
Those files then need to be loaded by your application.
For more details, see the example.
