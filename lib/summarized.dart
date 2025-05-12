import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:medical/screens/chat_screen.dart';

class ResultPage extends StatelessWidget {
  final String data;

  const ResultPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Summarized AI Result',
          style: TextStyle(
            color: Colors.green, // Text color green
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Full background Lottie animation
          /*Positioned.fill(
            child: Lottie.asset(
              //'assets/a4.json'
              ,
              repeat: true,
              width: 20,
              height: 20
            ),
          ),*/
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data,
                  style: const TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(data: data),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 140, 209, 241),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: const StadiumBorder(),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Lottie.asset(
                        'assets/a3.json',
                        width: 40,
                        height: 30,
                        repeat: true,
                      ),
                      const SizedBox(width: 8),
                      const Text("Chat with bot"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
