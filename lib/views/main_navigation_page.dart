import 'package:flutter/material.dart';
import 'home_page.dart';
import 'tasks_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    TasksPage(),
    Center(child: Text('Todas as Despesas')),
    Center(child: Text('Perfil')),
  ];

  final List<String> _titles = const [
    'Minhas Viagens',
    'Todas as Tarefas',
    'Todas as Despesas',
    'Perfil',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.card_travel),
            label: 'Viagens',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'Tarefas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Despesas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}