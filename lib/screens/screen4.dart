import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:languagelearning/screens/congratulations_screen.dart';
import 'package:lottie/lottie.dart';

class ScreenFour extends StatefulWidget {
  const ScreenFour({super.key});
  @override
  _ScreenFourState createState() => _ScreenFourState();
}

class _ScreenFourState extends State<ScreenFour> {
  final List<String> wordChoices = ['or', 'Hallo', 'yes', 'coffee', 'water'];
  String selectedWord = "";
  final AudioPlayer player = AudioPlayer();
  final FlutterTts flutterTts = FlutterTts();
  bool isCorrectAnswerSelected = false;
  bool isAnswerChecked = false;

  final Map<String, String> translations = {
    'option2': 'Hallo',
    'check': 'Check',
    'continue': 'Continue'
  };

  String translate(String key) {
    return translations[key] ?? key;
  }

  void _checkAnswer() {
    if (isAnswerChecked && isCorrectAnswerSelected) {
      setState(() {
        selectedWord = '';
        isCorrectAnswerSelected = false;
        isAnswerChecked = false;
      });

      // Navigate to the next screen if answer is correct and "Continue" is pressed
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => CongratulationsScreen()));
      return;
    }
    if (selectedWord.isEmpty) return;

    final isCorrect = selectedWord == translate('option2');
    _playSoundAndShowAnimation(context, isCorrect);
    setState(() {
      isCorrectAnswerSelected = isCorrect;
      isAnswerChecked = true;
    });
  }

  void _playSoundAndShowAnimation(BuildContext context, bool isCorrect) {
    String soundAsset =
    isCorrect ? 'assets/sound/success.mp3' : 'assets/sound/fail.mp3';
    player.setAsset(soundAsset).then((_) => player.play());
    _showBottomSheetWithAnimation(context, isCorrect ? 'success' : 'failure');
  }

  void _showBottomSheetWithAnimation(
      BuildContext context, String animationType) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return DraggableScrollableSheet(
            initialChildSize: 0.4,
            maxChildSize: 0.8,
            minChildSize: 0.2,
            builder: (_, controller) {
              return Container(
                color: Colors.black12,
                child: Center(
                  child: Lottie.asset(animationType == 'success'
                      ? 'assets/animation/correct.json'
                      : 'assets/animation/fail.json'),
                ),
              );
            },
          );
        });
  }

  void _playAudio(String text) async {
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
            backgroundColor: Colors.black12,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: const SizedBox(
              height: 25,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                child: LinearProgressIndicator(
                  value: 1,
                  backgroundColor: Colors.blueGrey,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
            )),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    "NEW WORD",
                    style: TextStyle(color: Colors.green, fontSize: 18),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Translate this sentence",
                    style: TextStyle(color: Colors.greenAccent, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/Images/cool1.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(
                          Icons.error,
                          size: 50,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          _playAudio("Hello!");
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(20)),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.volume_up,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                "Hello!",
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Wrap(
                    spacing: 10,
                    children: wordChoices.map((word) {
                      return ChoiceChip(
                          label: Text(word),
                          selected: selectedWord == word,
                          onSelected: (selected) {
                            setState(() {
                              selectedWord = word;
                            });
                          });
                    }).toList(),
                  )
                ],
              ),
            ),
            const Spacer(),
            Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 40.0, vertical: 100.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18)),
                  onPressed: _checkAnswer,
                  child: Center(
                    child: Text(
                      isCorrectAnswerSelected
                          ? translate('continue')
                          : translate('check'),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ))
          ],
        ));
  }
}
