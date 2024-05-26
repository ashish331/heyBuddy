import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hybuddy/mesage.dart';

class ChatState with ChangeNotifier {
  final List<Message> messages = [];
  FlutterTts flutterTts = FlutterTts();

  final Dio dio = Dio();

  Future<void> sendMessage(String text) async {
    messages.insert(0, Message(text, true)); // Add user message

    // Simulate AI response (replace with actual API call)
    final data = {
      'user_input': text,
    };

    try {
      // Send the POST request and store the response
      final response = await dio.post(
        'http://10.0.2.2:5000/send_message',
        data: data,
      );

      // Check for successful response (200 OK)
      if (response.statusCode == 200) {
        // Print the response data (assuming it's JSON)
        print(response.data);

        String textData = response.data['system_response'];

        messages.insert(0, Message(textData, false));

        notifyListeners();
        flutterTts.speak(textData);
      } else {
        // Handle unsuccessful response (e.g., print error message)
        print('Error creating data: ${response.statusCode}');
      }
    } catch (e) {
      // Handle DioError exceptions (e.g., network issues)
      messages.insert(0, Message('Error making request: ${e}', false));
      print('Error making request: ${e}');
    }
    notifyListeners();
    // Future.delayed(Duration(seconds: 1), () {

    // });
  }

  Future<void> initMessage(String text) async {
    // Simulate AI response (replace with actual API call)

    try {
      // Send the POST request and store the response
      final response = await dio.post(
        'http://10.0.2.2:5000/start_session',
      );

      // Check for successful response (200 OK)
    } catch (e) {
      // Handle DioError exceptions (e.g., network issues)
    }
    // notifyListeners();
    // Future.delayed(Duration(seconds: 1), () {

    // });
  }

  Future<void> setName(String text) async {
    // Simulate AI response (replace with actual API call)

    final data = {
      'user_input': text,
    };

    try {
      // Send the POST request and store the response
      final response = await dio.post(
        'http://10.0.2.2:5000/send_message',
        data: data,
      );

      // Send the POST request and store the response
      //

      // Check for successful response (200 OK)
    } catch (e) {
      // Handle DioError exceptions (e.g., network issues)
    }
    // notifyListeners();
    // Future.delayed(Duration(seconds: 1), () {

    // });
  }

  // Future<void> fetchData() async {
  //   final response =
  //       await http.get(Uri.parse('http://127.0.0.1::5000/send_message/'));
  //   if (response.statusCode == 200) {
  //     // Request successful, parse response data
  //     print('Response: ${response.body}');
  //   } else {
  //     // Request failed
  //     print('Failed to load data: ${response.statusCode}');
  //   }
  // }
}
