import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'auth_gate.dart';
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
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Future<FirebaseApp> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _initialize();
  }

  Future<FirebaseApp> _initialize() {
    return Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Firebase could not start. Check your setup.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _initialization = _initialize();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.message, size: 70, color: Colors.indigo),
                  SizedBox(height: 20),
                  Text(
                    'Message Board Vault Hunt',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Connecting to Firebase...'),
                ],
              ),
            ),
          );
        }

        return const AuthGate();
      },
    );
  }
}
