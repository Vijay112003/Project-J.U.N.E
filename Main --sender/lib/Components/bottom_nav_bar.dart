import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pc_connect/Components/_homeComponents.dart';
import 'package:pc_connect/Views/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BottomNavBar(),
    );
  }
}

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  int _volume = 50;

  final List<Widget> _pages = [
    HomeScreen(),
    Center(child: Text("Macros", style: TextStyle(fontSize: 24))),
    Center(child: Text("Terminal", style: TextStyle(fontSize: 24))),
    Center(child: Text("Settings", style: TextStyle(fontSize: 24))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      floatingActionButton: VoiceButton(
        onVoiceCommand: (text) {
          print("Sending voice command: $text");
          // MQTTHelper.publishMessage(
          //     'SENDER', '{"type": "voice", "text": "$text"}');
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: Colors.blue,
        notchMargin: 8.0,
        elevation: 10,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.085,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  HugeIcons.strokeRoundedHome11,
                  color: _selectedIndex == 0 ? Colors.white : Colors.black,
                ),
                onPressed: () => _onItemTapped(0),
              ),
              IconButton(
                icon: Icon(
                  HugeIcons.strokeRoundedGroup01,
                  color: _selectedIndex == 1 ? Colors.white : Colors.black,
                ),
                onPressed: () => _onItemTapped(1),
              ),
              SizedBox(width: 40), // Space for the floating action button
              IconButton(
                icon: Icon(
                  HugeIcons.strokeRoundedCommandLine,
                  color: _selectedIndex == 2 ? Colors.white : Colors.black,
                ),
                onPressed: () => _onItemTapped(2),
              ),
              IconButton(
                icon: Icon(
                  HugeIcons.strokeRoundedTools,
                  color: _selectedIndex == 3 ? Colors.white : Colors.black,
                ),
                onPressed: () => _onItemTapped(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
