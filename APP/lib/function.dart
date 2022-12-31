import 'dart:convert';
import 'package:http/http.dart' as http;

var data;
String output_api = 'No accident detected';
bool accidentDetected = false;
int shockValue = 0;
fetchdata (String url) async {
  print("test 4");
  final response = await http.get(Uri.parse(url));
  print("test 5");
  if(response.statusCode == 200){
    print("test 6");
    data = json.decode(response.body);
    print(data['0']['name']);
    data.forEach((key, value) => print("idx: $key, Hospital: ${value['name']}"));
  }
}