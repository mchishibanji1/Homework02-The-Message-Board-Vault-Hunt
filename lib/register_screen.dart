import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.auth});

  final AuthService auth;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _role = TextEditingController(text: 'student');
  bool _busy = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    _role.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_formKey.currentState!.validate()) return;

    setState(() => _busy = true);
    var accountCreated = false;

    try {
      final credential = await widget.auth.register(
        email: _email.text,
        password: _password.text,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Registration returned no user.');
      }

      accountCreated = true;

      await widget.auth.saveUserRecord(
        user,
        firstName: _firstName.text,
        lastName: _lastName.text,
        role: _role.text,
      );

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on FirebaseAuthException catch (error) {
      final message = switch (error.code) {
        'email-already-in-use' => 'That email is already registered.',
        'weak-password' => 'Password is too weak.',
        'invalid-email' => 'Enter a valid email address.',
        'network-request-failed' => 'Check your connection and try again.',
        _ => 'Registration failed. Please try again.',
      };

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (_) {
      if (mounted) {
        final message = accountCreated
            ? 'Account created, but profile was not saved. Retry profile save.'
            : 'Registration failed. Please try again.';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }

      if (accountCreated && mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _firstName,
                  decoration: const InputDecoration(labelText: 'First name'),
                  validator: (value) => (value?.trim().isEmpty ?? true)
                      ? 'First name required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _lastName,
                  decoration: const InputDecoration(labelText: 'Last name'),
                  validator: (value) => (value?.trim().isEmpty ?? true)
                      ? 'Last name required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (email.isEmpty) return 'Email required';
                    if (!email.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (value) {
                    final password = value ?? '';
                    if (password.isEmpty) return 'Password required';
                    if (password.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _role,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    helperText:
                        'Confirm required role values with your instructor.',
                  ),
                  validator: (value) =>
                      (value?.trim().isEmpty ?? true) ? 'Role required' : null,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: _busy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Register'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
