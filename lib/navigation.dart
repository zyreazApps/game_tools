import 'package:flutter/material.dart';
import 'package:game_tools/scoreboard.dart';
import 'package:game_tools/timer.dart';

import 'dashboard.dart';
import 'dice.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
 int _currentIndex = 0;

  final tabs = [
    const DashboardPage(),
    const ScoreboardPage(),
    const DicePage(),
    const TimerPage()
  ];

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: SafeArea(child: tabs[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.scoreboard),
            label: 'Scoreboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.casino),
            label: 'Dice',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Timer',
          ),
        ],
        showUnselectedLabels: true
      ),
    );
  }
}