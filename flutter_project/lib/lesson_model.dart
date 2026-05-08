class EDIPStep {
  final String content;
  final List<String>? scriptedCommands; // For Demonstrate phase

  EDIPStep({required this.content, this.scriptedCommands});
}

class LessonModule {
  final String id;
  final String title;
  final String analogy;
  final EDIPStep explain;
  final EDIPStep demonstrate;
  final EDIPStep imitate;
  final EDIPStep practice;

  LessonModule({
    required this.id,
    required this.title,
    required this.analogy,
    required this.explain,
    required this.demonstrate,
    required this.imitate,
    required this.practice,
  });
}

final List<LessonModule> academyModules = [
  LessonModule(
    id: 'navigation',
    title: 'Navigation',
    analogy: 'The Magic Map',
    explain: EDIPStep(content: 'ls is like a flashlight in a dark room. It shows you all the toy boxes (folders) nearby!'),
    demonstrate: EDIPStep(content: 'Watch how the wizard finds his way.', scriptedCommands: ['pwd', 'ls', 'ls -l']),
    imitate: EDIPStep(content: 'Type exactly what the wizard types: pwd'),
    practice: EDIPStep(content: 'Quest: Can you find the hidden cat in the attic? Hint: use ls.'),
  ),
  LessonModule(
    id: 'creation',
    title: 'Creation',
    analogy: 'The Building Spell',
    explain: EDIPStep(content: 'mkdir creates a brand new toy box. Just say the name, and it appears!'),
    demonstrate: EDIPStep(content: 'Watch the wizard build a kingdom.', scriptedCommands: ['mkdir castle', 'ls']),
    imitate: EDIPStep(content: 'Build your first box: mkdir my_box'),
    practice: EDIPStep(content: 'Quest: Create a box for your dragons and a box for your gold.'),
  ),
  // Add Manipulation, Deletion, and Permissions modules similarly...
];
