import 'package:flutter/material.dart';

class AgendaScreen extends StatelessWidget {
  const AgendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'This is the Agenda Screen!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
