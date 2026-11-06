import 'package:http/http.dart' as http;

import 'dart:convert';

/// Function to send data to the server
Future<Map<String, dynamic>> postData(
  String route,
  Map<String, dynamic> values,
) async {
  try {
    // Send a POST request to the server with the provided route and values
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000$route'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(values),
    );
    // Check if the response status code is 200 (OK)
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    // If the response status code is not 200, throw an exception
    else {
      throw Exception('Failed to post data.');
    }
  }
  // Catch any errors that occur during the request and print them to the console
  catch (err) {
    print(err);
    return {};
  }
}
