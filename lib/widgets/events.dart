import 'package:blue_notification/services/auth_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/events_handler.dart';

class EventListScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<FirestoreEvent>> _watchEvents() {
    return _firestore.collection('events')
        .orderBy('datetime')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => FirestoreEvent.fromFirestore(doc)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FirestoreEvent>>(
      stream: _watchEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Error loading events"));
        }

        final now = DateTime.now();
        final allEvents = snapshot.data ?? [];

        // Filter events based on datetimeEnd and closesBy to only show future events (but still display closed events)
        final events = allEvents
            .where((event) => event.datetimeEnd.toDate().isAfter(now) || event.closesBy.toDate().isAfter(now))
            .toList();

        final userId = FirebaseAuth.instance.currentUser?.uid;

        if (userId == null) {
          return const Center(child: Text("User not logged in"));
        }

        if (events.isEmpty) {
          return const Center(child: Text("No upcoming events"));
        }

        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            final isPastEvent = event.datetime.toDate().isBefore(DateTime.now());
            final isClosed = event.closesBy.toDate().isBefore(now);
            final isAttendee = event.attendees.any((ref) => ref.id == userId);

            final cardColor = isPastEvent
                ? Colors.red.shade100
                : (isAttendee ? Colors.green.shade700 : Colors.green.shade100);

            if (isAttendee){
              return Card.filled(
                //color: cardColor,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  onTap: () => _showEventDetailSheet(context, event, isAttendee),
                  title: Text(event.title),
                  subtitle: Text(
                    '${event.type}\nDate: ${DateFormat('d.M.yyyy \'at\' HH:mm').format(event.datetime.toDate())}',
                  ),
                  trailing: isClosed
                      ? Icon(Icons.lock, color: Colors.red) // Show lock icon for closed events
                      : IconButton(
                    icon: Icon(Icons.check_box_rounded),
                    onPressed: isClosed
                        ? null // Disable sign-up button if event is closed
                        : () => _toggleEventSignup(context, event, isAttendee), // Enable sign-up button for open events
                  ),
                ),
              );
            }

            return Card(
              //color: cardColor,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                onTap: () => _showEventDetailSheet(context, event, isAttendee),
                title: Text(event.title),
                subtitle: Text(
                  '${event.type}\nDate: ${DateFormat('d.M.yyyy \'at\' HH:mm').format(event.datetime.toDate())}',
                ),
                trailing: isClosed
                    ? Icon(Icons.lock, color: Colors.red) // Show lock icon for closed events
                    : IconButton(
                  icon: Icon(Icons.check_box_outline_blank_rounded),
                  onPressed: isClosed
                      ? null // Disable sign-up button if event is closed
                      : () => _toggleEventSignup(context, event, isAttendee), // Enable sign-up button for open events
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _toggleEventSignup(BuildContext context, FirestoreEvent event, bool isAttendee) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    try {
      final eventRef = FirebaseFirestore.instance.collection('events').doc(event.id);

      if (isAttendee) {
        await eventRef.update({
          'attendees': FieldValue.arrayRemove([userRef])
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("You have been signed off from the event."),
            duration: const Duration(milliseconds: 1500),
            padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0// Inner padding for SnackBar content.
            ),
            behavior: SnackBarBehavior.floating,),
        );
      } else {
        await eventRef.update({
          'attendees': FieldValue.arrayUnion([userRef])
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Signed up for the event!"),
            duration: const Duration(milliseconds: 1500),
            padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0// Inner padding for SnackBar content.
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating signup: $e")),
      );
    }
  }
}

// BOTTOM SHEET EVENT DETAIL

void _showEventDetailSheet(BuildContext context, FirestoreEvent event, bool isAttendee) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              event.description ?? 'No description',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.accessibility_new),
                const SizedBox(width: 8),
                Expanded(child: Text(event.type)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on),
                const SizedBox(width: 8),
                Expanded(child: Text(event.location)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 8),
                Text('From: ${DateFormat('d.M.yyyy \'at\' HH:mm').format(event.datetime.toDate())}\nUntil: ${DateFormat('d.M.yyyy \'at\' HH:mm').format(event.datetimeEnd.toDate())}'),
              ],
            ),
            const SizedBox(height: 8),
            /*Center(
              child: FilledButton.icon(
                icon: Icon(isAttendee ? Icons.check : Icons.add),
                label: Text(isAttendee ? "Signed up" : "Sign up"),
                onPressed: () {
                  Navigator.pop(context); // Close bottom sheet
                  _toggleEventSignup(context, event, isAttendee);
                },
              ),
            ),*/
            Row(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.access_time_filled),
                const SizedBox(width: 8),
                Text('Sign up by: ${DateFormat('d.M.yyyy \'at\' HH:mm').format(event.closesBy.toDate())}'),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {addCalendarEvent(event);},
              child: Text("Add to calendar"),
            )
          ],
        ),
      );
    },
  );
}
