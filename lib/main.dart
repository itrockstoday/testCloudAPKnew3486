import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'engine/terminal_engine.dart';
import 'screens/dashboard_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final engine = TerminalEngine();
  await engine.init();
  runApp(
    ChangeNotifierProvider.value(
      value: engine,
      child: const LinuxWizardApp(),
    ),
  );
}

class LinuxWizardApp extends StatelessWidget {
  const LinuxWizardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Linux Wizard Academy',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: Consumer<TerminalEngine>(
        builder: (context, engine, child) {
          if (!engine.isProfileSet) {
            return const ProfileScreen();
          }
          return const DashboardScreen();
        },
      ),
    );
  }
}
