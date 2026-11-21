import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'board_service.dart';
import 'message_model.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key, required this.user, required this.auth});

  final User user;
  final AuthService auth;

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  final BoardService _board = BoardService();
  final TextEditingController _textController = TextEditingController();
  bool _posting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _postMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _posting) return;

    setState(() => _posting = true);

    try {
      // Get the user's name from the Auth object or fallback
      final authorName = widget.user.displayName ?? 'Student';

      await _board.postMessage(
        authorUid: widget.user.uid,
        authorName: authorName,
        text: text,
      );
      _textController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to post: $e')));
      }
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Board'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.auth.signOut,
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _board.messageBoard(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet. Be the first to post!'),
                  );
                }

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMine = msg.authorUid == widget.user.uid;

                    return ListTile(
                      title: Text(msg.text),
                      subtitle: Text(
                        '${msg.authorName} • ${msg.createdAt != null ? msg.createdAt.toString().substring(0, 16) : 'Sending...'}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: isMine
                          ? IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _board.deleteMessage(messageId: msg.id);
                              },
                            )
                          : null,
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _posting ? null : _postMessage,
                  icon: _posting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
