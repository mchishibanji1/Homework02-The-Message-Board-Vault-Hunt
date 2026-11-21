import 'package:cloud_firestore/cloud_firestore.dart';

import 'message_model.dart';

class BoardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // CREATE
  Future<void> postMessage({
    required String authorUid,
    required String authorName,
    required String text,
  }) async {
    await _db.collection('messages').add({
      'text': text.trim(),
      'authorUid': authorUid,
      'authorName': authorName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // READ (Live Stream)
  Stream<List<Message>> messageBoard() {
    return _db
        .collection('messages')
        .orderBy('createdAt', descending: true) // Newest first
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList(),
        );
  }

  // UPDATE
  Future<void> editMessage({
    required String messageId,
    required String newText,
  }) async {
    await _db.collection('messages').doc(messageId).update({
      'text': newText.trim(),
      'editedAt': FieldValue.serverTimestamp(),
    });
  }

  // DELETE
  Future<void> deleteMessage({required String messageId}) async {
    await _db.collection('messages').doc(messageId).delete();
  }
}
