import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../engine/terminal_engine.dart';
import '../models/lesson.dart';

class ResumeScreen extends StatelessWidget {
  const ResumeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Resume'),
      ),
      body: Consumer<TerminalEngine>(
        builder: (context, engine, child) {
          List<String> skills = [];
          for (var lesson in appLessons) {
            if (engine.lessonProgress[lesson.id] == 4) {
              skills.add(lesson.skillEarned);
            }
          }

          int completedCount = skills.length;
          String jobTitle = "Linux Support Trainee";
          if (completedCount >= 3) jobTitle = "Helpdesk Technician (Linux)";
          if (completedCount >= 5) jobTitle = "Linux Associate";
          if (completedCount >= 7) jobTitle = "Junior Linux Systems Administrator";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.terminal, size: 60, color: Colors.indigo),
                        const SizedBox(height: 16),
                        Text(
                          '${engine.firstName} ${engine.lastName}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          jobTitle,
                          style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Proven ability to navigate, manage, and manipulate Unix-like operating systems via the command-line interface. Highly motivated IT professional with hands-on console experience.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[400], fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(engine.email ?? '', style: TextStyle(color: Colors.grey[300], fontSize: 12)),
                            const SizedBox(width: 8),
                            const Text('•', style: TextStyle(color: Colors.grey)),
                            const SizedBox(width: 8),
                            Text(engine.phone ?? '', style: TextStyle(color: Colors.grey[300], fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Emailing resume to ${engine.email}...')),
                            );
                          },
                          icon: const Icon(Icons.email),
                          label: const Text('Send to Email'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'PROFESSIONAL SUMMARY',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey),
                ),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Junior Linux Systems Administrator with practical training in core utilities. Capable of executing shell commands for file management, directory traversal, and rapid text operations. Ready to tackle server maintenance and automation scripting.',
                  style: TextStyle(color: Colors.grey[300], height: 1.5),
                ),
                const SizedBox(height: 24),
                const Text(
                  'TECHNICAL COMPETENCIES',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey),
                ),
                const Divider(),
                const SizedBox(height: 8),
                if (skills.isEmpty)
                  const Text(
                    'Complete academy modules to populate your professional competencies.',
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                  )
                else
                  ...skills.map((skill) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: Colors.grey[900],
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  skill,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ))
              ],
            ),
          );
        },
      ),
    );
  }
}
