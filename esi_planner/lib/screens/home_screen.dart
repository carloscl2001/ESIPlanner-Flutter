import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profile_service.dart';
import '../services/subject_service.dart';
import '../auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late ProfileService profileService;
  late SubjectService subjectService;

  bool isLoading = true;
  List<Map<String, dynamic>> subjects = [];
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    profileService = ProfileService();
    subjectService = SubjectService();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final String? username = Provider.of<AuthProvider>(context, listen: false).username;

    if (username == null) {
      if (mounted) {
        setState(() {
          errorMessage = 'Usuario no autenticado';
          isLoading = false;
        });
      }
      return;
    }

    try {
      final profileData = await profileService.getProfileData(username: username);

      final degree = profileData["degree"];
      final List<dynamic> userSubjects = profileData["subjects"] ?? [];

      if (degree != null && userSubjects.isNotEmpty) {
        List<Map<String, dynamic>> updatedSubjects = [];

        for (var subject in userSubjects) {
          final subjectData = await subjectService.getSubjectData(codeSubject: subject['code']);

          // Verificar los tipos de datos
          print('Tipos del usuario: ${subject['types']}');
          print('Tipo de subject[types]: ${subject['types'].runtimeType}');
          
          // Filtrar las clases según los tipos del usuario
          final List<dynamic> filteredClasses = subjectData['classes']
              .where((classData) {
                // Verificar si 'type' está presente en classData
                if (classData.containsKey('type')) {
                  final classType = classData['type'].toString(); // Asegurarse de que es una cadena
                  print('Tipo de classData[type]: $classType');
                  final bool isTypeMatching = subject['types'].contains(classType);
                  print('¿Tipo coincide? $isTypeMatching (Usuario: ${subject['types']}, Clase: $classType)');
                  return isTypeMatching;
                } else {
                  print('El campo "type" no está presente en classData');
                  return false; // Si no tiene 'type', no se incluye en los resultados
                }
              })
              .toList();

          // Ordenar los eventos de cada clase por fecha
          filteredClasses.forEach((classData) {
            classData['events'].sort((a, b) {
              DateTime dateA = DateTime.parse(a['date']);
              DateTime dateB = DateTime.parse(b['date']);
              return dateA.compareTo(dateB);
            });
          });

          // Ordenar las clases dentro de la asignatura por el primer evento de cada clase
          filteredClasses.sort((a, b) {
            DateTime dateA = DateTime.parse(a['events'][0]['date']);
            DateTime dateB = DateTime.parse(b['events'][0]['date']);
            return dateA.compareTo(dateB);
          });

          updatedSubjects.add({
            'name': subjectData['name'] ?? subject['name'],
            'code': subject['code'],
            'classes': filteredClasses, // Usar solo las clases filtradas
          });
        }

        if (mounted) {
          setState(() {
            subjects = updatedSubjects;
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            errorMessage = degree == null
                ? 'No se encontró el grado en los datos del perfil'
                : 'El usuario no tiene asignaturas';
            isLoading = false;
          });
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error al obtener los datos: $error';
          isLoading = false;
        });
      }
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Asignaturas disponibles', style: TextStyle(color: Colors.white)),
      centerTitle: true,
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                if (errorMessage.isNotEmpty) ...[
                  Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                ],
                Expanded(
                  child: ListView.builder(
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      final subject = subjects[index];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Mostrar solo las clases filtradas
                          ...subject['classes'].map<Widget>((classData) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // Card para cada evento
                                ...classData['events'].map<Widget>((event) {
                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    elevation: 4,
                                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Nombre de la asignatura dentro de la tarjeta
                                          Text(
                                            subject['name'] ?? 'No Name',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.indigo,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          // Tipo de clase
                                          Text(
                                            'Tipo de clase: ${classData['type']}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          // Información del evento
                                          Text(
                                            'Fecha: ${event['date']}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            'Hora: ${event['start_hour']} - ${event['end_hour']}',
                                          ),
                                          Text(
                                            'Ubicación: ${event['location']}',
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            );
                          }).toList(),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
  );
}

}
