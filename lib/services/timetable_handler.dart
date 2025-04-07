import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
// Timetable Entry Model
class TimetableEntry {
  final String type; // 'marching' or 'pause'
  final String startLocation;
  final DateTime startTime;
  final String stopLocation;
  final DateTime stopTime;
  final String? message;

  TimetableEntry({
    required this.type,
    required this.startLocation,
    required this.startTime,
    required this.stopLocation,
    required this.stopTime,
    this.message,
  });

  factory TimetableEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse Firestore document into TimetableEntry
    return TimetableEntry(
      type: data['type'],
      startLocation: data['start'][0], // GeoPoint for start
      startTime: (data['start'][1] as Timestamp).toDate(), // Timestamp to DateTime
      stopLocation: data['stop'][0], // GeoPoint for stop
      stopTime: (data['stop'][1] as Timestamp).toDate(), // Timestamp to DateTime
      message: (data['message']),
    );
  }

  bool isCurrent(DateTime currentTime) {
    return currentTime.isAfter(startTime) && currentTime.isBefore(stopTime);
  }
}

Future<List<TimetableEntry>> getTimetableEntries() async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('timetable') // Replace with your actual collection name
      .get();

  // Convert snapshot documents into TimetableEntry objects
  List<TimetableEntry> entries = querySnapshot.docs.map((doc) {
    final entry = TimetableEntry.fromFirestore(doc);
    return entry;
  }).toList();

  // Sort the entries by start time, which is stored as the second element in the "start" array
  entries.sort((a, b) {
    // Compare start time (second element of the "start" array) between a and b
    return a.startTime.compareTo(b.startTime);
  });

  return entries;
}

