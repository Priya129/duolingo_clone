import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:languagelearning/screens/screen3.dart';
import 'package:lottie/lottie.dart';

class ScreenTwo extends StatefulWidget {
  const ScreenTwo({super.key});

  @override
  _ScreenTwoState createState() => _ScreenTwoState();
}

class _ScreenTwoState extends State<ScreenTwo> {
  final Map<String, String> translations = {
    'subtitle': 'Complete the chat',
    'hello' : 'Hello, Julia!',
    'option1': 'Kaffee!',
    'option2':'Hallo!',
    'continue':'CONTINUE',
    'check':'CHECK'
  };

  final AudioPlayer player = AudioPlayer();
  final FlutterTts flutterTts = FlutterTts();
  String selectedOption = '';
  bool isCorrectAnswerSelected = false;
  bool isAnswerChecked = false;

  @override
  void initState(){
    super.initState();
    _initializeTts();
  }

  void _initializeTts() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);
  }

  void _speak(String text) async {
    if (text.isNotEmpty) {
      await flutterTts.speak(text);
    }
  }

  String translate(String key) {
    return translations[key] ?? key;
  }

  void _checkAnswer() {
    if(selectedOption.isEmpty) return;

    if(isAnswerChecked && isCorrectAnswerSelected) {
      setState(() {
        selectedOption = '';
        isCorrectAnswerSelected = false;
        isAnswerChecked = false;
      });
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => ScreenThree()));
      //Navigate to the next Screen
      return;
    }
    final isCorrect = selectedOption ==
    translate('option2');
    _playSoundAndShowAnimation(context, isCorrect);
    setState(() {
      isCorrectAnswerSelected = isCorrect;
      isAnswerChecked = true;
    });

  }

  void _playSoundAndShowAnimation(BuildContext context, bool isCorrect)  {
    String soundAsset =
        isCorrect ? 'assets/sound/success.mp3' :
            'assets/sound/fail.mp3';
    player.setAsset(soundAsset).then((_) =>
        player.play()
    );
    _showBottomSheetWithAnimation(
      context, isCorrect ? 'success' : 'failure'
    );

  }

  void _showBottomSheetWithAnimation(BuildContext context,
      String animationType){
    showModalBottomSheet(context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder:(context){
      return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 0.8,
          builder: (_, controller){
            return Container(
              color: Colors.black12,
              child: Center(
                child: Lottie.asset(
                  animationType == 'success'
                      ? 'assets/animation/correct.json'
                      : 'assets/animation/fail.json'
                ),
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black12,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 30),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: const SizedBox(
          height: 25,
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            child: LinearProgressIndicator(
              value: 0.5,
              backgroundColor: Colors.blueGrey,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.02,),
            Text(
              translate('subtitle'),
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.05,
              ),
            ),
            SizedBox(height: screenHeight * 0.02,),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.volume_up,
                    color: Colors.blueGrey, size: 30,
                  ),
                  onPressed: () => _speak(translate('hello')),
                ),
                SizedBox(width:  screenWidth * 0.02),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.01
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    translate('hello'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.04

                    ),
                  ),
                )
              ],
            ),
            const Spacer(),
            Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: selectedOption ==
                      translate('option1')
                      ? Colors.green
                        : Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)
                    )
                  ),
                    onPressed:(){
                    setState(() {
                      selectedOption = translate('option1');
                    });
                    } , child: Text(
                  translate('option1'),
                  style: TextStyle(fontSize: screenWidth * 0.04),
                )),
                SizedBox(height: screenHeight * 0.01,),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: selectedOption ==
                      translate('option2')
                      ? Colors.green
                        : Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    )
                  ),
                  onPressed: (){
                    setState(() {
                      selectedOption =
                          translate('option2');
                    });
                  },
                  child: Text(
                    translate('option2'),
                    style: TextStyle(fontSize: screenWidth * 0.04),
                  ),

                )
              ],
            ),
            SizedBox(height: screenHeight * 0.25,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0,
                vertical: 100.0
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),

                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                onPressed: _checkAnswer,
                child: Center(
                  child: Text(
                    isCorrectAnswerSelected && isAnswerChecked
                        ? translate('continue')
                        : translate('check'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}