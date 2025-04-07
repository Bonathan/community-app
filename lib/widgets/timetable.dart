import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

import '../services/timetable_handler.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentTime = DateTime.now();

    return FutureBuilder<List<TimetableEntry>>(
        future: getTimetableEntries(), // Fetch the timetable entries
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading timetable'));
          }

          if (snapshot.hasData) {
            final entries = snapshot.data!;
            return ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                bool isCurrent = entry.isCurrent(currentTime);

                return TimetableCard(entry: entry, isCurrent: isCurrent);
              },
            );
          }

          return Center(child: Text('No timetable available'));
        },
    );
  }
}

// Timetable Card UI
class TimetableCard extends StatelessWidget {
  final TimetableEntry entry;
  final bool isCurrent;

  TimetableCard({required this.entry, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final Color cardColor = entry.type == 'marching'
        ? Colors.blue.shade100 // Marching
        : Colors.green.shade100; // Break (pause)

    final bool hasPassed = entry.stopTime.isBefore(DateTime.now());
    final Color currentColor = hasPassed
        ? Colors.red.shade100 // Light red color for past entries
        : (isCurrent ? Colors.amber.shade300 : cardColor); // Existing logic for current or future entries


    // Format the start and stop times
    String startFormatted = DateFormat('HH:mm').format(entry.startTime);
    String stopFormatted = DateFormat('HH:mm').format(entry.stopTime);

    return Card(
      color: currentColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              entry.type == 'marching' ? Icons.directions_walk : Icons.pause,
              color: Colors.black,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${startFormatted} at ${entry.startLocation}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${stopFormatted} at ${entry.stopLocation}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: entry.message != null, // If message is null, it won't be visible
              child: Text(entry.message!),
            ),
            if (isCurrent)
              Icon(
                Icons.star,
                color: Colors.amber,
              ),
          ],
        ),
      ),
    );
  }
}
