import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

class FirestoreEvent {
  final String id;
  final String title;
  final String description;
  final String location;
  final String type;
  final Timestamp datetime;
  final Timestamp datetimeEnd;
  final Timestamp closesBy;
  final DocumentReference createdBy;
  final List<DocumentReference> attendees;
  final String eventStatus;

  FirestoreEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.type,
    required this.datetime,
    required this.datetimeEnd,
    required this.closesBy,
    required this.createdBy,
    required this.attendees,
    required this.eventStatus,
  });

  // Factory to convert Firestore DocumentSnapshot to Event
  factory FirestoreEvent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FirestoreEvent(
      id: doc.id.toString(),
      title: data['title'],
      description: data['description'],
      location: data['location'],
      type: data['type'],
      datetime: data['datetime'],
      datetimeEnd: data['datetimeEnd'],
      closesBy: data['closesBy'],
      createdBy: data['createdBy'],
      attendees: List<DocumentReference>.from(data['attendees'] ?? []),
      eventStatus: data['eventStatus'],
    );
  }

  // Method to check if user is already attending the event
  bool isUserAttending(String userId) {
    return attendees.any((ref) => ref.id == userId);
  }
}

void addCalendarEvent (FirestoreEvent firestoreEvent) {
  final Event event = Event(
    title: firestoreEvent.title,
    description: firestoreEvent.description,
    location: firestoreEvent.location,
    startDate: firestoreEvent.datetime.toDate(),
    endDate: firestoreEvent.datetimeEnd.toDate(),
    /*iosParams: IOSParams(
      reminder: Duration(/* Ex. hours:1 */), // on iOS, you can set alarm notification after your event.
      url: 'https://www.example.com', // on iOS, you can set url to your event.
    ),*/
    androidParams: AndroidParams(
      emailInvites: [], // on Android, you can add invite emails to your event.
    ),
  );
  Add2Calendar.addEvent2Cal(event); //TODO: Add iOS integration: look here https://pub.dev/packages/add_2_calendar#ios-integration
}
