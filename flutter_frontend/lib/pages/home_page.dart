// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  final User user;
  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bem-vindo, ${user.displayName ?? 'Usuário'}'),
      ),
      body: Center(
        child: Text(
          'Olá, ${user.email}',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
