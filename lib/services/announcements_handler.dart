import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final DocumentReference<Map<String, dynamic>> createdBy; // Add this field

  Announcement({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.createdBy,  // Constructor needs to include createdBy
  });

  // Updated fromFirestore factory
  factory Announcement.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Announcement(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      createdBy: data['createdBy'] as DocumentReference<Map<String, dynamic>>, // Map the createdBy field
    );
  }
}

Stream<List<Announcement>> streamAnnouncements() {
  final oneDayAgo = DateTime.now().subtract(Duration(days: 1));

  return FirebaseFirestore.instance
      .collection('announcements')
      .where('timestamp', isGreaterThan: oneDayAgo)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => Announcement.fromFirestore(doc)).toList();
  });
}
