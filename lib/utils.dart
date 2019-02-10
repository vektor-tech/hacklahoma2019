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
    // If the call to the server was successful, parse the JSON
    print(response.body);
    return ClassifiedObject.fromJson(json.decode(response.body));
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}

class ClassifiedObject {
  List<Entity> ent;

  ClassifiedObject();

  factory ClassifiedObject.fromJson(Map<String, dynamic> json) {
    return ClassifiedObject();
  }
}

class Entity {
  String mid;
  String name;
  double score;
  List<double> coordinates;
}
