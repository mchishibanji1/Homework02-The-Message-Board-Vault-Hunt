import 'package:cloud_firestore/cloud_firestore.dart';

import 'message_model.dart';

class BoardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // CREATE (Spice #4 & #5 applied)
  Future<void> postMessage({
    required String authorUid,
    required String authorName,
    required String text,
  }) async {
    // Spice #4: Idempotent Alchemist
    // Create a deterministic ID based on the user and the text.
    // If they double tap, it just overwrites the exact same document.
    final docId = '${authorUid}_${text.trim().hashCode}';

    await _db.collection('messages').doc(docId).set({
      'text': text.trim(),
      'authorUid': authorUid,
      'authorName': authorName,
      'createdAt': FieldValue.serverTimestamp(),
      'schemaVersion': 1, // Spice #5: Schema Shape-shifter
    });
  }

  // READ (Spice #6 applied)
  Stream<List<Message>> messageBoard() {
    return _db
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(50) // Spice #6: Batch Librarian (Pagination limit)
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
