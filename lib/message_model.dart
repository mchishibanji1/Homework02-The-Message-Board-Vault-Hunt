import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String text;
  final String authorUid;
  final String authorName;
  final DateTime?
  createdAt; // Nullable because it might be pending server write
  final DateTime? editedAt;

  Message({
    required this.id,
    required this.text,
    required this.authorUid,
    required this.authorName,
    this.createdAt,
    this.editedAt,
  });

  factory Message.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Message(
      id: doc.id,
      text: data['text'] ?? '',
      authorUid: data['authorUid'] ?? '',
      authorName: data['authorName'] ?? 'Unknown',
      // Server timestamps can be null for a split second while being written
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      editedAt: (data['editedAt'] as Timestamp?)?.toDate(),
    );
  }
}
