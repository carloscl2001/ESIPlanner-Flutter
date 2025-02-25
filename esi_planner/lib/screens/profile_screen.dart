import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_cards.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Perfil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.indigo,
      ),
      body: Column(
        children: [
          // GridView con las tarjetas reutilizando CustomCard
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              children: const [
                CustomCard(
                  text: 'Mi perfil',
                  icon: Icons.person,
                  route: '/viewProfile',
                ),
                CustomCard(
                  text: 'Cambiar la contraseña',
                  icon: Icons.lock,
                  route: '/editPassWordProfile',
                ),
                CustomCard(
                  text: 'Mis asignaturas',
                  icon: Icons.school,
                  route: '/viewSubjectsProfile',
                ),
                CustomCard(
                  text: 'Cambiar mis asignaturas',
                  icon: Icons.edit,
                  route: '/editSubjectsProfile',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}