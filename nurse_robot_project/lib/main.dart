import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/patient_service.dart';
import 'services/arduino_service.dart';
import 'screens/nurse_home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NurseRobotApp());
}

class NurseRobotApp extends StatelessWidget {
  const NurseRobotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PatientService()),
        ChangeNotifierProvider(create: (_) => ArduinoService()),
      ],
      child: MaterialApp(
        title: 'Smart Nurse Robot',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00796B),
            primary: const Color(0xFF00796B),
            secondary: const Color(0xFFFFB300),
          ),
          fontFamily: 'Roboto',
        ),
        home: const NurseHomeScreen(),
      ),
    );
  }
}
