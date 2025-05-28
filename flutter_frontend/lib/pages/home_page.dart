// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import '../widgets/wine_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ... carregamento de nome de usuário ...

  @override
  Widget build(BuildContext context) {
    // se quiser manter o appBar com nome:
    return Scaffold(
      appBar: AppBar(title: Text('Bem-vindo!')),
      body: const WineList(), 
    );
  }
}
