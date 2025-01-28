import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

import 'package:mecab_for_dart/mecab_dart.dart';
import 'package:mecab_for_dart/token_node.dart';
import "helper.dart"
  if (dart.library.js_interop) "helper_web.dart"
  if (dart.library.io) "helper_native.dart";

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// controller for the dynamic text input
  TextEditingController controller =
    TextEditingController(text: 'にわにわにわにわとりがいる。');
  /// used platform version
  String platformVersion = 'Unknown';
  /// result of mecab
  String text = "";
  /// mecab instance
  var tagger = new Mecab();
  ///
  List<TokenNode> tokens = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    try {

      // this example ships a mecab dictionary in assets
      // alternatively you can dowlaod it from somwhere
      String ipaDictPath = await getDictDir("assets/ipadic/", null);

      // Initialize mecab tagger here 
      //   + 1st parameter : dictionary folder
      //   + 2nd parameter : additional mecab options
      await tagger.init(, ipaDictPath, true);

      print("Connection to the C-side established: ${tagger.mecabDartFfi.nativeAddFunc(3, 3) == 6}");

      tokens = tagger.parse(controller.text);

    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() { });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Mecab Dart - example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                maxLines: null,
                onChanged: ((value) => setState(() {
                  tokens = tagger.parse(controller.text);
                  print(tokens.first.surface.length);
                }))
              ),
              SizedBox(height: 20,),
              SingleChildScrollView(
                child: SelectionArea(
                  child: Table(
                    children: [
                      TableRow(
                        children: ["surface", "POS", "Base", "Reading", "Pronunciation"].map((e) => 
                          Center(
                            child: Text(e)
                          )
                        ).toList()
                      ),
                      ...tokens
                        .where((token) => token.features.length == 9)
                        .map((t) => 
                          TableRow(
                            children: [
                              SelectableText(t.surface),
                              SelectableText(t.features.sublist(0, 4).toString()),
                              SelectableText(t.features[4]),
                              SelectableText(t.features[7]),
                              SelectableText(t.features[8])
                            ]
                          )
                        ).toList()
                    ]
                  ),
                ),
              ),
            ]
          ),
        ),
      ),
    );
  }

}
