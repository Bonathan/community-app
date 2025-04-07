import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/announcements_handler.dart';

class AnnouncementListScreen extends StatelessWidget {
  const AnnouncementListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Announcement>>(
      stream: streamAnnouncements(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Failed to load announcements'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No announcements yet.'));
        }

        final announcements = snapshot.data!;
        return ListView.builder(
          itemCount: announcements.length,
          itemBuilder: (context, index) {
            return buildAnnouncementCardWithInitial(announcements[index]);
          },
        );
      },
    );
  }

  String _formatTimestamp(Timestamp ts) {
    final dt = ts.toDate();
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} - ${dt.day}.${dt.month}.${dt.year}";
  }
}

Widget buildAnnouncementCardWithInitial(Announcement a) {
  return FutureBuilder<DocumentSnapshot>(
    future: a.createdBy.get(), // Fetch the user's document using createdBy reference
    builder: (context, snapshot) {
      String? initial;
      bool isNew = false; // Flag to determine if the announcement is new

      // Handle the snapshot states
      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasData) {
          // Check if document exists
          if (snapshot.data != null && snapshot.data!.exists) {
            // User document exists, get the name
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final name = userData['name'] ?? '';
            if (name.isNotEmpty) {
              initial = name[0].toUpperCase(); // Take the first letter of the name
            } else {
              initial = '?'; // Fallback if the name is empty
            }
          } else {
            // Document does not exist or is deleted
            initial = '?'; // Display a question mark when the user doesn't exist
          }
        } else if (snapshot.hasError) {
          // If there's an error (like user document doesn't exist)
          initial = '?'; // Display a question mark
        }

        // Calculate if the announcement is newer than 5 minutes
        final timeDifference = DateTime.now().difference(a.timestamp);
        if (timeDifference.inMinutes <= 5) {
          isNew = true; // Mark as new if the announcement is within 5 minutes
        }
      }

      return Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).colorScheme.primary,  // Using the primary color from the theme
                    child: Text(
                      initial ?? '?', // Show '?' if the initial is null
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary, // Text color that contrasts well with primary
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(a.message),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('dd.MM.yyyy – HH:mm').format(a.timestamp),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Add the "New" badge if the announcement is less than 5 minutes old
              if (isNew)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}
