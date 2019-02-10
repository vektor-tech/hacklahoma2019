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
    await flutterTts.stop();
    var result = await flutterTts.speak(text);
  }

  void takePic(int option) async {
    while (true) {
      final Directory extDir = await getApplicationDocumentsDirectory();
      final String dirPath = '${extDir.path}/Pictures/flutter_test';
      await Directory(dirPath).create(recursive: true);
      final String filePath = '$dirPath/${timestamp()}.jpg';
      await controller.takePicture(filePath);

      File image = File(filePath);
      List<int> imageBytes = image.readAsBytesSync();
      String base64Image = base64Encode(imageBytes);

      var a = await fetchPost(base64Image, option);
      text = "";

      if (option == 1) {
        for (var i = 0; i < a.ent.length; i++) {
          print(a.ent[i].name);
          for (var j = 0; j < 8; j++) {
            print(a.ent[i].coordinates[j]);
          }
          if (a.ent[i].score > 0.7) {
            text += a.ent[i].name + ", ";
          }
        }
      } else if (option == 0) {
        for (var i = 0; i < a.ent.length; i++) {
          text += a.ent[i].description;
        }
      } else {
        double max = 9;
        var index;
        for (var i = 0; i < a.ent.length; i++) {
          if (a.ent[i].score > max) {
            max = a.ent[i].score;
            index = i;
          }
          text += a.ent[index].color;
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
      resizeToAvoidBottomPadding: true,
      backgroundColor: const Color.fromRGBO(169, 217, 188, 1.0),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(169, 217, 188, 1.0),
        title: Text('Seeker',
            style: TextStyle(
                color: const Color.fromRGBO(0, 138, 136, 1.0),
                fontSize: 30.0,
                fontFamily: 'Raleway')),
      ),
      body: Column(
        children: <Widget>[
          AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: CameraPreview(controller)),
          Expanded(
            child: Container(
              margin: EdgeInsets.all(5.0),
              child: SingleChildScrollView(
                child: Text(text,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton(
                onPressed: () async {
                  await flutterTts.stop();
                  await flutterTts.speak("Detecting Texts");
                  takePic(0);
                },
                child: Icon(Icons.text_format,
                    color: const Color.fromRGBO(0, 138, 136, 1.0)),
                backgroundColor: const Color.fromRGBO(255, 213, 138, 1.0)),
            SizedBox(
              width: 20.0,
            ),
            FloatingActionButton(
                onPressed: () async {
                  await flutterTts.stop();
                  await flutterTts.speak("Detecting Objects");
                  takePic(1);
                },
                child: Icon(Icons.camera,
                    color: const Color.fromRGBO(0, 138, 136, 1.0)),
                backgroundColor: const Color.fromRGBO(255, 213, 138, 1.0)),
            SizedBox(
              width: 20.0,
            ),
            FloatingActionButton(
                onPressed: () async {
                  await flutterTts.stop();
                  await flutterTts.speak("Detecting Color");
                  //  takePic(2);
                },
                child: Icon(Icons.colorize,
                    color: const Color.fromRGBO(0, 138, 136, 1.0)),
                backgroundColor: const Color.fromRGBO(255, 213, 138, 1.0)),
          ],
        ),
      ),
    );
  }
}
