import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:languagelearning/screens/screen2.dart';
import 'package:lottie/lottie.dart';

class ScreenOne extends StatefulWidget {
  const ScreenOne({super.key});

  @override
  ScreenOneState createState() => ScreenOneState();
}

class ScreenOneState extends State<ScreenOne> {
  final FlutterTts flutterTts = FlutterTts();
  late final OnDeviceTranslator translator;
  final player = AudioPlayer();

  String word = '';
  List<Map<String, dynamic>> options = [];
  String selectdOption = '';

  @override
  void initState() {
    super.initState();
    translator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.english,
      targetLanguage: TranslateLanguage.german,
    );
    _fetchQuestion();
  }

  @override
  void dispose() {
    translator.close();
    player.dispose();
    super.dispose();
  }

  void _speak(String text) async {
    await flutterTts.setLanguage('de');
    await flutterTts.speak(text);
  }

  void _handleSelection(String text) {
    setState(() {
      selectdOption = text;
    });
  }

  void _checkAnswer() {
    final option = options.firstWhere(
      (option) => option['text'] == selectdOption,
      orElse: () => {},
    );

    bool isCorrect = option['isCorrect'] == true;

    _playSoundAndShowAnimation(context, isCorrect);
  }

  void _playSoundAndShowAnimation(BuildContext context, bool isCorrect) {
    String soundAsset =
        isCorrect ? 'assets/sound/success.mp3' : 'assets/sound/fail.mp3';
    player.setAsset(soundAsset).then((_) => player.play());

    String animationType = isCorrect ? 'success' : 'failure';
    _showBottomSheetWithAnimation(context, animationType, isCorrect);
  }

  void _showBottomSheetWithAnimation(
    BuildContext context,
    String animationType,
    bool isCorrect,
  ) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.2,
              maxChildSize: 0.8,
              builder: (_, controller) {
                return Container(
                  color: Colors.black12,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(animationType == 'success'
                          ? 'assets/animation/correct.json'
                          : 'assets/animation/fail.json'),
                      if (isCorrect) ...[
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ScreenTwo()));
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          child: const Text(
                            'CONTINUE',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        )
                      ]
                    ],
                  ),
                );
              });
        });
  }

  Future<void> _fetchQuestion() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('questions')
          .doc('question1')
          .get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          String fetchedWord = data['word'] ?? 'No Question';
          List<dynamic> fetchedOptions = data['options'] ?? [];

          String translatedWord = await translator.translateText(fetchedWord);
          List<Map<String, dynamic>> translatedOptions =
              fetchedOptions.map((option) {
            return {
              'text': option['text'],
              'image': option['image'],
              'isCorrect': option['isCorrect']
            };
          }).toList();

          setState(() {
            word = translatedWord;
            options = translatedOptions;
          });
        }
      } else {
        print('No question found');
      }
    } catch (e) {
      print('Error fetching or translating question: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const SizedBox(
          height: 25,
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            child: LinearProgressIndicator(
              value: 0.25,
              backgroundColor: Colors.blueGrey,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.volume_up,
                      color: Colors.blueGrey, size: 30),
                  onPressed: () => _speak(word),
                ),
                Expanded(
                  child: Text(
                    word,
                    style: const TextStyle(
                        fontSize: 24, color: Colors.greenAccent),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            const Text('Select the correct image',
                style: TextStyle(fontSize: 24)),
            const SizedBox(
              height: 20,
            ),
            Expanded(
                child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
              itemCount: options.length,
              itemBuilder: (context, index) {
                String optionText = options[index]['text'];
                String imageUrl = options[index]['image'];
                return GestureDetector(
                  onTap: () {
                    _handleSelection(optionText);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1),
                        borderRadius: BorderRadius.circular(10),
                        color: selectdOption == optionText
                            ? Colors.green
                            : Colors.grey[800]),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(
                              color: Colors.greenAccent,
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          optionText,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                );
              },
            )),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 90.0),
              child: Container(
                height: 50,
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                    onPressed: _checkAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                    ),
                    child: const Text(
                      'CHECK',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5),
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }
}
