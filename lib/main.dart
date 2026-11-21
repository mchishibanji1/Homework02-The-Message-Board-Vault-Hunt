import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MessageBoardApp());
}

class MessageBoardApp extends StatelessWidget {
  const MessageBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Message Board Vault Hunt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const FirebaseSplashScreen(),
    );
  }
}

class FirebaseSplashScreen extends StatefulWidget {
  const FirebaseSplashScreen({super.key});

  @override
  State<FirebaseSplashScreen> createState() => _FirebaseSplashScreenState();
}

class _FirebaseSplashScreenState extends State<FirebaseSplashScreen> {
  String status = 'Connecting to Firebase...';

  @override
  void initState() {
    super.initState();
    initializeFirebase();
  }

  Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      if (!mounted) return;

      setState(() {
        status = 'Firebase connected successfully!';
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        status = 'Firebase connection failed: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final connected = status == 'Firebase connected successfully!';

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.message, size: 70, color: Colors.indigo),
              const SizedBox(height: 20),
              const Text(
                'Message Board Vault Hunt',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              if (!connected &&
                  !status.startsWith('Firebase connection failed'))
                const CircularProgressIndicator(),
              if (connected)
                const Icon(Icons.check_circle, color: Colors.green, size: 35),
              const SizedBox(height: 15),
              Text(status, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
