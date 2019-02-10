import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

Future<ClassifiedObject> fetchPost(String image) async {
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
          "type":"OBJECT_LOCALIZATION"
        }
      ]
    }
  ]
}''');

  if (response.statusCode == 200) {
    // print(response.body);
    return ClassifiedObject.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load post');
  }
}

class ClassifiedObject {
  List<Entity> ent;

  ClassifiedObject({this.ent});

  factory ClassifiedObject.fromJson(Map<String, dynamic> json) {
    var a = [];
    if (json != null) {
      a = json['responses'][0]['localizedObjectAnnotations'];
    }
    List<Entity> b = [];
    for (var i = 0; i < a.length; i++) {
      b.add(Entity.fromJson(a[i]));
    }
    return ClassifiedObject(ent: b);
  }
}

class Entity {
  String mid;
  String name;
  double score;
  List<double> coordinates;

  Entity({this.mid, this.name, this.score, this.coordinates});

  factory Entity.fromJson(Map<String, dynamic> json) {
    var a = [];
    if (json != null) {
      a = json['boundingPoly']['normalizedVertices'];
    }
    List<double> b = [];
    for (var i = 0; i < a.length; i++) {
      b.add(a[i]['x'].toDouble());
      b.add(a[i]['y'].toDouble());
    }
    return Entity(
        mid: json['mid'],
        name: json['name'],
        score: json['score'],
        coordinates: b);
  }
}
