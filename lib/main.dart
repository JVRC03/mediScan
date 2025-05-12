import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:lottie/lottie.dart';
import 'summarized.dart'; // Assuming ResultPage is defined here
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mediscan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'MediScan'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const scanChannel = MethodChannel("scanPlatform");
  Database? database;
  String result = '';

  @override
  void initState() {
    super.initState();
    initDB();
  }

  Future<void> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'people.db');

    database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE people (
            id INTEGER PRIMARY KEY,
            name TEXT
          )
        ''');

        await db.insert('people', {'id': 1, 'name': 'liver'});
        await db.insert('people', {'id': 2, 'name': 'low hemoglobin'});
        await db.insert('people', {'id': 4, 'name': 'sinus'});
        await db.insert('people', {'id': 6, 'name': 'PSA'});
        await db.insert('people', {'id': 8, 'name': 'hyperthyroidism'});
      },
    );
  }

  Future<void> searchName(String scannedResult) async {
    if (database == null) {
      setState(() {
        result = 'Database not ready';
      });
      return;
    }

    final List<Map<String, dynamic>> records = await database!.query(
      'people',
      where: 'name = ?',
      whereArgs: [scannedResult],
    );

    setState(() {
      result = records.isNotEmpty ? 'Found: ${records.first['name']}' : 'Not found';
    });
  }

  @override
  void dispose() {
    database?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          // Lottie Background
          Positioned.fill(
            child: Lottie.asset(
              'assets/a1.json',
              width: 300, // Adjust as needed
              height: 300,
              repeat: true,
            ),
          ),
          // Centered Button
          Center(
            child: ElevatedButton(
              onPressed: () async {
                try {
                  final String scannedData = await scanChannel.invokeMethod('scan');

                  debugPrint("Flutter : $scannedData");

                  Fluttertoast.showToast(
                    msg: "Processing...",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black54,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );

                  await Future.delayed(const Duration(seconds: 2));

                  await searchName(scannedData);

                  if (result != 'Not found' && context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResultPage(data: scannedData),
                      ),
                    );
                  } else {
                    Fluttertoast.showToast(
                      msg: 'No matching entry found.',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                  }
                } on PlatformException catch (e) {
                  Fluttertoast.showToast(
                    msg: e.message ?? "Failed",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                  debugPrint("Fail ${e.message}");
                }
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
      'assets/a2.json',
      width: 30,
      height: 30,
      repeat: true,
    ),
    const SizedBox(width: 8),
    const Text("Scan QR"),
  ],
),

            ),
          ),
        ],
      ),
    );
  }
}
