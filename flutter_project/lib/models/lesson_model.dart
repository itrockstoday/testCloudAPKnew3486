import 'package:flutter/foundation.dart';

class LessonChallenge {
  final String prompt;
  final String target;

  LessonChallenge({required this.prompt, required this.target});
}

class LessonModel {
  final String id;
  final String command;
  final String title;
  final String analogy;
  final String explanation;
  final List<String> demonstrations;
  final List<LessonChallenge> challenges;

  LessonModel({
    required this.id,
    required this.command,
    required this.title,
    required this.analogy,
    required this.explanation,
    required this.demonstrations,
    required this.challenges,
  });
}

class LearningState extends ChangeNotifier {
  List<LessonModel> lessons = [
    LessonModel(
      id: 'ls',
      command: 'ls',
      title: 'ls (List Secrets)',
      analogy: 'The "X-Ray Vision" spell',
      explanation: 'Use this to see everything inside your current magic box!',
      demonstrations: ['ls', 'ls -l'],
      challenges: [
        LessonChallenge(prompt: "Type exactly: ls", target: "ls"),
        LessonChallenge(prompt: "Check your box: ls", target: "ls"),
      ],
    ),
    // Additional lessons added here...
  ];

  int currentLessonIndex = 0;
  String currentStage = "Explain";

  LessonModel get currentLesson => lessons[currentLessonIndex];

  void nextStage() {
    // Logic for transitioning between Explain -> Demonstrate -> Imitate -> Practice
    notifyListeners();
  }
}
