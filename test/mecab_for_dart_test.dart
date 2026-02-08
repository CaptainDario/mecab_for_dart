import 'dart:convert';
import 'dart:isolate';

import 'package:mecab_for_dart/mecab_dart.dart';
import 'package:test/test.dart';
import 'dart:io';

import 'test_utils.dart';


void main() {

  // Determine the library name based on the OS
  String libmecabName = "lib dir/mecab" + () {
    if (Platform.isMacOS) return ".dylib";
    else if (Platform.isLinux) return ".so";
    else if (Platform.isWindows) return ".dll";
    else throw UnsupportedError("Unsupported platform");
  } ();

  String ipadicDir = "ipa dic";
  String unidicDir = "unidic";
  
  test('test mecab for dart', () async {
    print(Directory.current);
    double preInitMemory = currentMemoryUsage();
    print("Memory usage before init: $preInitMemory MB");
    final tagger = await Mecab.create(libmecabName, ipadicDir, "");
    double postInitMemory = currentMemoryUsage();
    print("Memory usage after init: $postInitMemory MB");
    expect(postInitMemory-10 > preInitMemory, true);

    final surfaces = tagger.parse("林檎を食べる").map((e) => e.surface,).toList();
    expect(surfaces, ["林檎", "を", "食べる", "EOS"]);
    tagger.dispose();
    //await Future.delayed(Duration(milliseconds: 5000)); // Wait for memory to be freed

    double postDisposeMemory = currentMemoryUsage();
    print("Memory usage after dispose(+wait): $postDisposeMemory MB");
  });


  test('test mecab memory sharing across isolates', () async {
  // 1. Initialize in the main isolate
    final mainTagger = await Mecab.create(libmecabName, ipadicDir, "");
    final stateJson = mainTagger.transferableState.toJson(); 
    
    // 2. Gather data from the isolate
    // Return a Map or a Record with the data we want to verify
    final (surfaces, memoryJump) = await Isolate.run(() async {
      final preIsolateInitMemory = currentMemoryUsage();
      
      final state = MecabTransferableState.fromJson(stateJson);
      final isolateTagger = await Mecab.fromTransferableState(state);
      
      final postIsolateInitMemory = currentMemoryUsage();
      final results = isolateTagger.parse("桃を食べる").map((e) => e.surface).toList();
      print("Parsing result in isoalte: $results");
      
      isolateTagger.dispose();
      
      // Return the data to the main isolate instead of calling expect() here
      return (results, postIsolateInitMemory - preIsolateInitMemory);
    });

    // 3. Perform expectations in the main isolate scope
    print("Memory jump in isolate: $memoryJump MB");
    expect(surfaces, ["桃", "を", "食べる", "EOS"]);
    
    // Verify the dictionary wasn't reloaded (should be near 0MB, definitely < 5MB)
    expect(memoryJump < 5, true, reason: "Memory jump was too high, dictionary likely reloaded!");
    
    mainTagger.dispose();
  });

test('test multiple dictionaries simultaneously', () async {
    // 1. Create taggers
    print("Memory usage before init: ${currentMemoryUsage()} MB");
    final ipaTagger = await Mecab.create(libmecabName, ipadicDir, "");
    print("Memory usage after IPA init: ${currentMemoryUsage()} MB");
    final uniTagger = await Mecab.create(libmecabName, unidicDir, "");
    print("Memory usage after UniDic init: ${currentMemoryUsage()} MB");

    const input = "図書館";

    // 4. Parse
    final ipaTokens = ipaTagger.parse(input).map((e) => e.surface).toList();
    final uniTokens = uniTagger.parse(input).map((e) => e.surface).toList();

    print("Input: $input");
    print("IPADic result: $ipaTokens");
    print("UniDic result: $uniTokens");

    // 5. Assert they are different
    expect(ipaTokens, isNot(equals(uniTokens)));
    
    // 6. Dispose both
    ipaTagger.dispose();
    uniTagger.dispose();
  });

  test('test different options', () async {
    List<String> options = ["", "-Owakati", "-Oyomi"];
    List<String> expectedOutputs = [
      "林檎\t名詞,一般,*,*,*,*,林檎,リンゴ,リンゴ\n"
      "を\t助詞,格助詞,一般,*,*,*,を,ヲ,ヲ\n"
      "食べる\t動詞,自立,*,*,一段,基本形,食べる,タベル,タベル\n"
      "EOS",
      "林檎 を 食べる",
      "リンゴヲタベル",
    ];
    for (int i = 0; i < options.length; i++) {
      final tagger = await Mecab.create(libmecabName, ipadicDir, options[i]);

      final output = tagger.rawParse("林檎を食べる");
      print("");
      print(output);
      expect(output, expectedOutputs[i]);
      tagger.dispose();
    }
  });

}