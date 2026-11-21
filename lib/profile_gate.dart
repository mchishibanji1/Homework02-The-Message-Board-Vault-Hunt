import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'board_screen.dart';

class ProfileGate extends StatefulWidget {
  const ProfileGate({super.key, required this.user, required this.auth});

  final User user;
  final AuthService auth;

  @override
  State<ProfileGate> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<ProfileGate> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _profile;

  @override
  void initState() {
    super.initState();
    _profile = _load();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _load() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .get();
  }

  bool _hasRequiredFields(Map<String, dynamic>? data) {
    if (data == null) return false;
    return data['uid'] is String &&
        data['firstName'] is String &&
        data['lastName'] is String &&
        data['role'] is String &&
        data['registrationDateTime'] != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: _profile,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Profile')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Could not load your profile.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => setState(() => _profile = _load()),
                    child: const Text('Retry'),
                  ),
                  TextButton(
                    onPressed: widget.auth.signOut,
                    child: const Text('Sign out'),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data?.data();

        if (!_hasRequiredFields(data)) {
          return Scaffold(
            appBar: AppBar(title: const Text('Profile incomplete')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Your Firestore user record is missing fields.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => setState(() => _profile = _load()),
                    child: const Text('Retry'),
                  ),
                  TextButton(
                    onPressed: widget.auth.signOut,
                    child: const Text('Sign out'),
                  ),
                ],
              ),
            ),
          );
        }

        return BoardScreen(
          key: ValueKey(widget.user.uid),
          user: widget.user,
          auth: widget.auth,
        );
      },
    );
  }
}
