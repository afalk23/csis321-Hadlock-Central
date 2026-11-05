import 'package:http/http.dart' as http;
import 'dart:convert';

Future <Map<String, dynamic>> postData(String route, Map<String, dynamic> values) async{
  try{
    final response = await http.post(Uri.parse('http://127.0.0.1:5000$route'),
        headers: <String, String>{
          'Content-Type':'application/json; charset=UTF-8',
        },body: jsonEncode(values)
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    else {
      throw Exception('Failed to post data.');
    }
  }
  catch(err){
    print(err);
    return {};
  }


}