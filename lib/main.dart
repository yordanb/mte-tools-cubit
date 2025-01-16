// Struktur file: lib/main.dart

import 'package:fl_cubit_tool_mgmt/screen/help_page.dart';
import 'package:fl_cubit_tool_mgmt/screen/home.dart';
import 'package:fl_cubit_tool_mgmt/screen/setting_page.dart';
import 'package:fl_cubit_tool_mgmt/screen/pinjam_page.dart';
import 'package:fl_cubit_tool_mgmt/screen/tools_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/tools_cubit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tools App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => ToolsCubit(),
        child: const MainPage(),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    ToolsPage(),
    PinjamPage(),
    SettingPage(),
    HelpPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.shifting,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 16.0,
        unselectedFontSize: 12.0,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        elevation: 12.0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Katalog',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Transaksi',
          ),
          /*
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          
          BottomNavigationBarItem(
            icon: Icon(Icons.help),
            label: 'Help',
          ),
          */
        ],
      ),
    );
  }
}
