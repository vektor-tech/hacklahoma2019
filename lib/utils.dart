import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

Future<ClassifiedObject> fetchPost(String image, int option) async {
  var type = "";
  if (option == 1) {
    type = "OBJECT_LOCALIZATION";
  } else if (option == 0) {
    type = "TEXT_DETECTION";
  } else {
    type = "IMAGE_PROPERTIES";
  }
  final response = await http.post(
      'https://vision.googleapis.com/v1/images:annotate?key=AIzaSyD3z2J3fiKVWaKbqTevDSivNjttuul6PdU',
      body: '''{
  "requests":[
    {
      "image":{
        "content":"$image"
      },
      "features":[
        {
          "type":"$type"
        }
      ]
    }
  ]
}''');

  if (response.statusCode == 200) {
    // print(response.body);
    return ClassifiedObject.fromJson(json.decode(response.body), option);
  } else {
    throw Exception('Failed to load post');
  }
}

class ClassifiedObject {
  List<Entity> ent;

  ClassifiedObject({this.ent});

  factory ClassifiedObject.fromJson(Map<String, dynamic> json, int option) {
    var a = [];
    if (option == 1) {
      a = json['responses'][0]['localizedObjectAnnotations'];
    } else if (option == 0) {
      a = json['responses'][0]['textAnnotations'];
    } else {
      a = json['responses'][0]['imagePropertiesAnnotation']['dominantColors']
          ['colors'];
    }
    List<Entity> b = [];
    for (var i = 0; i < a.length; i++) {
      b.add(Entity.fromJson(a[i], option));
    }
    return ClassifiedObject(ent: b);
  }
}

class Entity {
  String mid;
  String name;
  String description;
  double score;
  List<double> coordinates;
  String color;

  Entity(
      {this.mid,
      this.name,
      this.score,
      this.coordinates,
      this.description,
      this.color});

  factory Entity.fromJson(Map<String, dynamic> json, int option) {
    var a = [];

    String x;
    if (option == 1) {
      a = json['boundingPoly']['normalizedVertices'];
    } else if (option == 0) {
      a = json['boundingPoly']['vertices']; //array
    } else {
      if (json['color']['red'] > json['color']['blue'] &&
          json['color']['red'] > json['color']['green']) {
        x = "red";
      } else if (json['color']['blue'] > json['color']['red'] &&
          json['color']['blue'] > json['color']['green']) {
        x = "blue";
      } else {
        x = "green";
      }
      return Entity(color: x, score: json['score']);
    }

    List<double> b = [];
    for (var i = 0; i < a.length; i++) {
      b.add(a[i]['x'].toDouble());
      b.add(a[i]['y'].toDouble());
    }
    if (option == 1) {
      return Entity(
          mid: json['mid'],
          name: json['name'],
          score: json['score'],
          coordinates: b);
    } else {
      return Entity(description: json['description'], coordinates: b);
    }
  }
}
