import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../engine/terminal_engine.dart';
import '../models/lesson.dart';
import 'terminal_screen.dart';
import 'resume_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _viewAllModules = false;

  void _startLessonAndNavigate(TerminalEngine engine, Lesson lesson) {
    engine.startLesson(lesson);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TerminalScreen()),
    );
  }

  Widget _buildLessonCard(TerminalEngine engine, Lesson lesson, int progress) {
    String statusText = 'Not Started';
    Color statusColor = Colors.grey;
    if (progress == 4) {
      statusText = 'Completed (Replay)';
      statusColor = Colors.green;
    } else if (progress > 0) {
      statusText = 'In Progress';
      statusColor = Colors.orange;
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _startLessonAndNavigate(engine, lesson),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.menu_book, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lesson.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(lesson.explanation),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 4),
                  Icon(
                    progress == 4 ? Icons.check_circle : Icons.play_circle_fill,
                    color: statusColor,
                    size: 32,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Linux Wizard Academy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment_ind),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ResumeScreen()),
              );
            },
            tooltip: 'My Wizard Resume',
          )
        ],
      ),
      body: Consumer<TerminalEngine>(
        builder: (context, engine, child) {
          if (_viewAllModules) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => setState(() => _viewAllModules = false),
                      ),
                      const Text('All Modules', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: appLessons.length,
                    itemBuilder: (context, index) {
                      final lesson = appLessons[index];
                      int progress = engine.lessonProgress[lesson.id] ?? 0;
                      return _buildLessonCard(engine, lesson, progress);
                    },
                  ),
                ),
              ],
            );
          }

          int completedCount = appLessons.where((l) => (engine.lessonProgress[l.id] ?? 0) == 4).length;
          Lesson nextLesson = appLessons.firstWhere(
            (l) => (engine.lessonProgress[l.id] ?? 0) < 4, 
            orElse: () => appLessons.last
          );
          int nextProgress = engine.lessonProgress[nextLesson.id] ?? 0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).cardColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome back, ${engine.firstName}!', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      'You have completed $completedCount out of ${appLessons.length} modules.',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      onPressed: () => setState(() => _viewAllModules = true),
                      child: const Text('View All Modules'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  completedCount == appLessons.length ? 'You completed everything! Replay a module:' : 'Up Next:',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildLessonCard(engine, nextLesson, nextProgress),
              ),
            ],
          );
        },
      ),
    );
  }
}
