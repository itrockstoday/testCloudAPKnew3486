import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xterm/xterm.dart';
import 'terminal_service.dart';
import 'lesson_model.dart';
import 'resume_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TerminalService()),
      ],
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
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
      ),
      home: const AcademyHomeScreen(),
    );
  }
}

class AcademyHomeScreen extends StatefulWidget {
  const AcademyHomeScreen({super.key});

  @override
  State<AcademyHomeScreen> createState() => _AcademyHomeScreenState();
}

class _AcademyHomeScreenState extends State<AcademyHomeScreen> {
  int _currentModuleIndex = 0;
  String _currentStage = "Explain"; // Explain, Demonstrate, Imitate, Practice

  @override
  Widget build(BuildContext context) {
    final terminalService = Provider.of<TerminalService>(context);
    final module = academyModules[_currentModuleIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wizard Academy'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentModuleIndex + 1) / academyModules.length,
          ),
        ),
      ),
      body: Column(
        children: [
          // Top: Educational Guide
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(20),
              color: Theme.of(context).cardColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(module.title, style: Theme.of(context).textTheme.headlineMedium),
                  Text(module.analogy, style: const TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Text(_getStageContent(module), style: const TextStyle(fontSize: 16)),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: _nextStage,
                        child: const Text("Next Step"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          // Bottom: Terminal
          Expanded(
            flex: 3,
            child: TerminalView(
              terminalService.terminal,
              controller: terminalService.terminalController,
              backgroundOpacity: 1,
            ),
          ),
        ],
      ),
    );
  }

  String _getStageContent(LessonModule module) {
    switch (_currentStage) {
      case "Explain": return module.explain.content;
      case "Demonstrate": return module.demonstrate.content;
      case "Imitate": return module.imitate.content;
      case "Practice": return module.practice.content;
      default: return "";
    }
  }

  void _nextStage() {
    setState(() {
      if (_currentStage == "Explain") _currentStage = "Demonstrate";
      else if (_currentStage == "Demonstrate") _currentStage = "Imitate";
      else if (_currentStage == "Imitate") _currentStage = "Practice";
      else {
        _currentStage = "Explain";
        _currentModuleIndex = (_currentModuleIndex + 1) % academyModules.length;
      }
    });
  }
}
