import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_tts/flutter_tts.dart';

import './utils.dart';

List<CameraDescription> cameras;

Future<void> main() async {
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraApp(),
      debugShowCheckedModeBanner: false,
      color: Colors.orangeAccent,
    );
  }
}

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  CameraController controller;
  FlutterTts flutterTts = new FlutterTts();
  var text = "";

  @override
  void initState() {
    super.initState();
    initializeSpeech();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void initializeSpeech() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(1.0);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<void> textToSpeech(String text) async {
    var result = await flutterTts.speak(text);
    //if (result == 1) setState(() => ttsState = TtsState.playing);
  }

  void takePic() async {
    while (true) {
      final Directory extDir = await getApplicationDocumentsDirectory();
      final String dirPath = '${extDir.path}/Pictures/flutter_test';
      await Directory(dirPath).create(recursive: true);
      final String filePath = '$dirPath/${timestamp()}.jpg';
      await controller.takePicture(filePath);

      File image = File(filePath);
      List<int> imageBytes = image.readAsBytesSync();
      String base64Image = base64Encode(imageBytes);

      var a = await fetchPost(base64Image);
      text = "";
      for (var i = 0; i < a.ent.length; i++) {
        print(a.ent[i].name);
        print(a.ent[i].score);
        if (a.ent[i].score > 0.7) {
          text += a.ent[i].name + ", ";
        }
      }
      print(text);
      setState(() {});
      await textToSpeech(text);
      sleep(const Duration(seconds: 3));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreenAccent,
      appBar: AppBar(
        backgroundColor: Colors.lightGreenAccent,
        title: Text('Vision'),
      ),
      body: Column(
        children: <Widget>[
          AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: CameraPreview(controller)),
          Container(
            margin: EdgeInsets.all(3.0),
            child: Text(text,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: takePic,
        child: Icon(Icons.camera),
        backgroundColor: Colors.limeAccent,
      ),
    );
  }
}
