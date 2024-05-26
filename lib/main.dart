// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider12/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart'; // Import speech_to_text

import 'messageList.dart';
import 'state/chatstate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HyBuddy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatState state = ChatState();
  final TextEditingController _controller = TextEditingController();
  final SpeechToText _speechToText =
      SpeechToText(); // Create SpeechToText object
  bool _isListening = false;
  String voiceData = '';
  FlutterTts flutterTts = FlutterTts();

  String? language;
  String? engine;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;

  String? _newVoiceText;
  int? _inputLength;

  bool isSpeaking = false;
  bool isboy = false;

  @override
  void initState() {
    super.initState();

    _speechToText.listen(onResult: (result) => _onRecognitionResult(result));

    _getDefaultEngine();
    _getDefaultVoice();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: state,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Buddy"),
          actions: [
            IconButton(
              icon: Icon(
                isboy ? Icons.boy : Icons.girl, // Dynamic icon based on state
              ),
              onPressed: () {
                // Toggle text-to-speech functionality and speaker icon state

                isboy = !isboy;
                isboy ? flutterTts.setPitch(1.0) : flutterTts.setPitch(2.0);
                setState(() async {
                  // flutterTts.speak('hyyyyy');
                  // print(result);

                  // Implement your text-to-speech logic here, potentially changing voice to female
                });
              },
            ),
            IconButton(
              icon: Icon(
                isSpeaking
                    ? Icons.volume_up
                    : Icons.volume_off, // Dynamic icon based on state
              ),
              onPressed: () {
                // Toggle text-to-speech functionality and speaker icon state
                setState(() {
                  isSpeaking = !isSpeaking;
                  isSpeaking ? flutterTts.speak(voiceData) : flutterTts.stop();

                  // Implement your text-to-speech logic here, potentially changing voice to female
                });
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(child: MessageList(messages: state.messages)),
            Container(
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                border: Border(
                    top: BorderSide(
                  color: Colors.grey,
                  width: 0.5,
                  style: BorderStyle.solid,
                )),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                            hintText: 'Enter a prompt here',
                            border: InputBorder.none),
                        enabled:
                            !_isListening, // Disable TextField when listening
                      ),
                    ),
                  ),
                  IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        state.sendMessage(_controller.text);
                        _controller.clear();
                      }),
                  IconButton(
                      icon: Icon(_isListening ? Icons.mic : Icons.mic_off),
                      onPressed: _toggleListening)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _toggleListening() async {
    if (!_isListening) {
      final debouncedStartListening = debounce(() async {
        bool available = await _speechToText.initialize(
          onStatus: (status) {
            // print(voiceData);
            // print('Status: $status');
            // if (status == 'notListening') {
            //   print(voiceData);
            //   // state.sendMessage(_speechToText.lastRecognizedWords);
            // }
            switch (status) {
              // case 'hearing':
              //   setState(() => _isListening = true);
              //   break;
              case 'done':
                print(voiceData);
                if (voiceData.isNotEmpty) state.sendMessage(voiceData);
                voiceData = '';
                print('cancelled');
                _speechToText.stop();
                setState(() => _isListening = false);
                break;

              case 'completed':
                // print('completed');
                break;
              case 'error':
                setState(() => _isListening = false);
                break;
            }
          },
          onError: (error) => print('Error: $error'),
        );
        if (available) {
          setState(() => _isListening = true);
          _speechToText.listen(onResult: _onRecognitionResult);
        }
      }, Duration(milliseconds: 250)); // Adjust delay as needed

      debouncedStartListening();
    } else {
      setState(() => _isListening = false);
      _speechToText.stop();
    }
  }

// Debounce implementation (assuming you don't have one):
  Function debounce(Function func, Duration duration) {
    Timer? timer;

    return () {
      if (timer != null) {
        timer!.cancel();
      }
      timer =
          Timer(duration, () => func()); // Wrap func in an anonymous function
    };
  }

  void _onRecognitionResult(SpeechRecognitionResult result) {
    if (result.recognizedWords.isNotEmpty) {
      voiceData = result.recognizedWords;

      // _controller.text = result.recognizedWords;
    }
  }

  Future _speak({required String text}) async {
    var result = await flutterTts.speak(text);
    // if (result == 1) setState(() => ttsState = TtsState.playing);
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    // if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future<dynamic> _getLanguages() async => await flutterTts.getLanguages;

  Future<dynamic> _getEngines() async => await flutterTts.getEngines;

  Future<void> _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future<void> _getDefaultVoice() async {
    var voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      print(voice);
    }
  }

  Future<void> _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }
}
