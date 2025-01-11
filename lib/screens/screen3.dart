import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:languagelearning/screens/screen4.dart';

class ScreenThree extends StatefulWidget {
  const ScreenThree({super.key});

  @override
  _ScreenThreeState createState() => _ScreenThreeState();

}

class _ScreenThreeState extends State<ScreenThree> {
  final FlutterTts flutterTts = FlutterTts();
  List<Map<String, String>> pairs = [];
  List<Map<String, String>> shuffledPairs = [];
  String? selectedName;
  bool showResult = false;
  bool isCorrect = false;
  int matchCount = 0;

  @override
  void initState() {
    super.initState();
    fetchPairsFromFirestore();
  }

  Future<void> fetchPairsFromFirestore() async {
    try {
      final collectionRef =
          FirebaseFirestore.instance.collection('matchingPairs');
      QuerySnapshot snapshot = await collectionRef.get();

      setState(() {
        pairs = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'key': data['key'] as String,
            'name': data['name'] as String,
          };
        }).toList();

        shuffledPairs = [...pairs]..shuffle(Random());
      });
    } catch(e) {
      print('Error fetching data from Firestore: $e');
    }
  }

  void handleMatch(String name) {
    setState(() {
      isCorrect = (name == selectedName);
      showResult = true;
      if(isCorrect) matchCount++;
    });

    Future.delayed(const Duration(seconds: 1), (){
      setState(() {
        selectedName = null;
        showResult = false;
      });
    });
  }

  Future<void> playName(String name) async {
    await flutterTts.speak(name);
    setState(() {
      selectedName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: const SizedBox(
          height: 25,
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            child: LinearProgressIndicator(
              value: 0.75,
              backgroundColor: Colors.blueGrey,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),

        ),
      ),
      body: pairs.isEmpty
        ? const Center(child: CircularProgressIndicator(),)
          : Padding (
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/Images/cool.png',
                  width: 50,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error,
                    size: 50, color: Colors.red,
                  ),
                ),
                const SizedBox(width: 10,),
                const Text(
                  'Match the sound with its correct name',
                  style: TextStyle(fontSize: 16, color: Colors.greenAccent),
                )
              ],
            ),
            const SizedBox(height: 20,),
            Expanded(
              child: ListView(
                children: [
                  const Text(
                    'Select a sound:',
                    style: TextStyle(
                      fontSize: 18, color: Colors.white),
                      textAlign: TextAlign.center
                    ),
                  const SizedBox(height: 10,),
                  ...pairs.map((pair) => buildAudioButton(pair['name']!)),
                  const Divider(color: Colors.white, thickness: 1,),
                  const SizedBox(height: 10,),
                  const Text(
                    'Match the name:',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  ...shuffledPairs
                  .map((pair) => buildMatchingButton(pair['name']!)),
                  if(showResult)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        isCorrect ? 'Correct!' : 'Try Again!',
                        style: TextStyle(
                          fontSize: 24,
                          color: isCorrect ? Colors.green : Colors.red,
                        ),
                        textAlign: TextAlign.center,

                      ),
                    ),
                  if(matchCount >= 3)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30.0),
                      child: ElevatedButton(onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder:
                            (context) => ScreenFour()));
                      },
                          style: ElevatedButton.styleFrom(
                            padding:
                              const EdgeInsets.symmetric(vertical: 18),
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)
                            )
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(fontSize: 20),
                          )),
                    )

                ],
              ),
            )
          ],
        ),
      )
    );

  }

  Widget buildAudioButton(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () => playName(name),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[900]
          ),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: const Center(
            child: Icon(
              Icons.volume_up,
              color: Colors.blueGrey,
              size: 24.0,

            ),
          )
        ),
      ),
    );
  }

  Widget buildMatchingButton(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: ()=> handleMatch(name),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[800]
          ),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Center(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20
              ),
            ),
          ),
        ),
      ),
    );
  }
}