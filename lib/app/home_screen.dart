import 'package:blue_notification/widgets/announcements.dart';
import 'package:blue_notification/widgets/events.dart';
import 'package:blue_notification/widgets/timetable.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // To track the selected tab index

  // List of pages for each navigation item (a, b, c, d)
  final List<Widget> _pages = [
    Center(child: AnnouncementListScreen()), // Placeholder for "a"
    Center(child: TimetableScreen()), // Placeholder for "b"
    Center(child: EventListScreen()), // Placeholder for "c"
    Center(child: Text('Page D')), // Placeholder for "d"
  ];

  final List<String> _titles = [
    "Announcements",
    "Timetable",
    "Calendar",
    "Location",
  ];

  // Method to handle bottom navigation tab selection
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index; // Update selected tab index
    });
  }
  int currentPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[currentPageIndex])),
      body: _pages[currentPageIndex], // Display the corresponding page
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: <Widget>[
          NavigationDestination(
            icon: Icon(Icons.notifications_none),
            label: _titles[0],
          ),
          NavigationDestination(
            icon: Icon(Icons.list),
            label: _titles[1],
          ),
          NavigationDestination(
            icon: Icon(Icons.today),
            label: _titles[2],
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            label: _titles[3],
          ),
        ],
      ),
    );
  }
}
