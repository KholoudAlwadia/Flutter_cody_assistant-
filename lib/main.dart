// @dart=2.9
library watson_assistant_v2;

import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:avatar_glow/avatar_glow.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:watson_assistant_v2/watson_assistant_v2.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:rive/rive.dart';






void main() async  {
  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Voice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF000000),
        primarySwatch:  Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SpeechScreen(
      ),

    );
  }
}
String _text = 'Press the button and start speaking';
String res;
String currentAnimation = "reposo";
bool _watsonstate = false;

class SpeechScreen extends StatefulWidget {
  @override
  SpeechScreenState createState() => SpeechScreenState();
}

class SpeechScreenState extends State<SpeechScreen> {
  final FlutterTts flutterTts = FlutterTts();

  WatsonAssistantV2Credential credential = WatsonAssistantV2Credential(
    version: '2019-02-28',
    apikey: 'qq5TlEg-CtJcstv_zhtoRCI4_-vKN_ijgKZIomRaN--o',
    assistantID: 'cbab29c1-ee01-49b1-ab5b-d30c00aa6079',
    url: 'https://api.eu-gb.assistant.watson.cloud.ibm.com/instances/95ccabbe-29e3-4318-8255-0b5387ff2f0e/v2',
  );

  WatsonAssistantApiV2 watsonAssistant;
  WatsonAssistantResponse watsonAssistantResponse;
  WatsonAssistantContext watsonAssistantContext =
  WatsonAssistantContext(context: {});


  void _callWatsonAssistant() async {
    watsonAssistantResponse = await watsonAssistant.sendMessage(
        _text, watsonAssistantContext);

    setState(() async {
      res = watsonAssistantResponse.resultText;
      print(res);
      if (currentAnimation == "reposo") {
        setState(() {
          currentAnimation = "reposo 2";
        });
        await flutterTts.setPitch(1.4);
        await flutterTts.speak(res);
        watsonAssistantContext = watsonAssistantResponse.context;
      }else{ setState(() {
        currentAnimation = "reposo";
      });}
    });
  }

  void statuse() {
    if (currentAnimation == "reposo 2") {
      setState(() {
        currentAnimation = "reposo";
      });
    }
  }

  final Map<String, HighlightedWord> _highlight = {

    'cody': HighlightedWord(
      onTap: () => print('cody'),
      textStyle: const TextStyle(
        color: Colors.pink,
        fontWeight: FontWeight.bold,
      ),
    ),

    'good': HighlightedWord(
      onTap: () => print('good'),
      textStyle: const TextStyle(
        color: Colors.tealAccent,
      ),
    ),
    'bad': HighlightedWord(
      onTap: () => print('bad'),
      textStyle: const TextStyle(
        color: Colors.redAccent,
      ),
    ),
    'thank you': HighlightedWord(
      onTap: () => print('Thank you'),
      textStyle: const TextStyle(
        color: Colors.amberAccent,
      ),
    ),
  };

  stt.SpeechToText _speech;
  bool _isListening = false;

  double _confidence = 1.0;


  @override
  void initState() {
    super.initState();

    _speech = stt.SpeechToText();
    watsonAssistant =
        WatsonAssistantApiV2(watsonAssistantCredential: credential);
    _callWatsonAssistant();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('cody assistant'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: AvatarGlow(
          animate: _isListening,
          glowColor: Theme
              .of(context)
              .primaryColor,
          endRadius: 75.0,
          duration: const Duration(milliseconds: 2000),
          repeatPauseDuration: const Duration(milliseconds: 100),
          repeat: true,
          child: FloatingActionButton(
            child: Icon(_isListening ? Icons.mic : Icons.mic_none),
            onPressed: _listen,
          ),
        ),
        body: ListView(
          reverse: true,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                width: 700,
                height: 300,
                child: TextHighlight(
                  text: _text,
                  words: _highlight as LinkedHashMap<String, HighlightedWord>,
                  textStyle: const TextStyle(
                    fontSize: 32.0,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            Padding(padding: const EdgeInsets.all(8.0),
              child: Container(
                  width: 400,
                  height: 700,
                  child: FlareActor(
                    'assets/robot.flr',
                    animation: currentAnimation,
                  )
              ),)

          ],
        )
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) =>
              setState(() {
                _text = val.recognizedWords;
                if (val.hasConfidenceRating && val.confidence > 0) {
                  _confidence = val.confidence;
                  print(_text);
                  _callWatsonAssistant();
                }
              }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      if (_isListening == false)
        setState(() {
          currentAnimation = "reposo";
        });
    }
  }
}



