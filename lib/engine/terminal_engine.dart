import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/lesson.dart';

class TerminalLine {
  final String text;
  final bool isCommand;
  TerminalLine({required this.text, this.isCommand = false});
}

class TerminalEngine extends ChangeNotifier {
  List<TerminalLine> output = [];
  late Directory _homeDir;
  late Directory _currentDir;
  SharedPreferences? _prefs;

  // Progress state
  Map<String, int> lessonProgress = {}; // lessonId -> state (0: none, 1: demonstrate, 2: imitate, 3: practice, 4: completed)
  int currentStageIndex = 0; // index within demonstrate/imitate/practice phase

  // Profile State
  String? firstName;
  String? lastName;
  String? email;
  String? phone;

  bool get isProfileSet => firstName != null && lastName != null && email != null && phone != null;

  Lesson? activeLesson;
  String currentPhase = 'none'; // 'none', 'demonstrate', 'imitate', 'practice'

  String get currentPath => _currentDir.path;

  String get currentInstruction {
    if (activeLesson == null) return '';
    switch (currentPhase) {
      case 'demonstrate':
        return 'Watch closely! Press ENTER or any key to see the next command.';
      case 'imitate':
        if (currentStageIndex < activeLesson!.imitations.length) {
          return 'Type exactly this: ${activeLesson!.imitations[currentStageIndex]}';
        }
        return '';
      case 'practice':
        if (currentStageIndex < activeLesson!.practices.length) {
          return 'Challenge: ${activeLesson!.practices[currentStageIndex].description}';
        }
        return '';
      default:
        return '';
    }
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Setup a safe sandbox directory
    final appDocDir = await getApplicationDocumentsDirectory();
    _homeDir = Directory(p.join(appDocDir.path, 'linux_academy_home'));
    if (!_homeDir.existsSync()) {
      _homeDir.createSync(recursive: true);
    }

    // Pre-populate realistic folder structure for the modules if empty
    final prepDirs = ['Coloring_Books', 'Puzzles', 'Action_Figures'];
    for (var d in prepDirs) {
      final dir = Directory(p.join(_homeDir.path, d));
      if (!dir.existsSync()) dir.createSync();
    }
    final prepFiles = {'spell_book.txt': 'Spells and magic formulas...', 'magic_wand.sh': 'echo "Wave!"', 'potions_recipe.md': '# Potions\n1. Eye of newt...'};
    prepFiles.forEach((name, content) {
      final file = File(p.join(_homeDir.path, name));
      if (!file.existsSync()) file.writeAsStringSync(content);
    });
    
    final secretFile = File(p.join(_homeDir.path, '.secret_diary'));
    if (!secretFile.existsSync()) secretFile.writeAsStringSync('Top Secret Spell Book');
    final hiddenOrb = File(p.join(_homeDir.path, '.hidden_orb'));
    if (!hiddenOrb.existsSync()) hiddenOrb.writeAsStringSync('Glowing faintly...');

    _currentDir = _homeDir;

    // Load progress and profile
    _loadProgress();
    _loadProfile();
    
    _printWelcome();
    notifyListeners();
  }

  void _loadProgress() {
    final keys = _prefs!.getKeys();
    for (String key in keys) {
      if (key.startsWith('lesson_')) {
        String lessonId = key.replaceAll('lesson_', '');
        lessonProgress[lessonId] = _prefs!.getInt(key) ?? 0;
      }
    }
  }

  void _loadProfile() {
    firstName = _prefs!.getString('profile_firstName');
    lastName = _prefs!.getString('profile_lastName');
    email = _prefs!.getString('profile_email');
    phone = _prefs!.getString('profile_phone');
  }

  void saveProfile(String fName, String lName, String mail, String pNum) {
    firstName = fName;
    lastName = lName;
    email = mail;
    phone = pNum;
    _prefs!.setString('profile_firstName', fName);
    _prefs!.setString('profile_lastName', lName);
    _prefs!.setString('profile_email', mail);
    _prefs!.setString('profile_phone', pNum);
    notifyListeners();
  }

  void _saveProgress(String lessonId, int state) {
    lessonProgress[lessonId] = state;
    _prefs!.setInt('lesson_$lessonId', state);
    notifyListeners();
  }

  void startLesson(Lesson lesson) {
    activeLesson = lesson;
    currentPhase = 'demonstrate';
    currentStageIndex = 0;
    _saveProgress(lesson.id, 1);
    output.clear();
    _printLine('Starting lesson: ${lesson.title}');
    _printLine(lesson.explanation);
    _printLine('--- DEMONSTRATION PHASE ---');
  }

  void _promptImitate() {
    if (activeLesson != null && currentStageIndex < activeLesson!.imitations.length) {
      String expected = activeLesson!.imitations[currentStageIndex];
      _printLine('Now it\'s your turn! Type exactly this: $expected');
    } else if (activeLesson != null && currentStageIndex >= activeLesson!.imitations.length) {
      currentPhase = 'practice';
      currentStageIndex = 0;
      _saveProgress(activeLesson!.id, 3);
      _printLine('--- PRACTICE PHASE ---');
      _promptPractice();
    }
    notifyListeners();
  }

  void _promptPractice() {
    if (activeLesson != null && currentStageIndex < activeLesson!.practices.length) {
      String task = activeLesson!.practices[currentStageIndex].description;
      _printLine('CHALLENGE: $task');
    } else if (activeLesson != null) {
      _saveProgress(activeLesson!.id, 4);
      _printLine('🌟 LESSON COMPLETE: ${activeLesson!.title} 🌟');
      _printLine('Skill Unlocked: ${activeLesson!.skillEarned}');
      activeLesson = null;
      currentPhase = 'none';
      currentStageIndex = 0;
    }
    notifyListeners();
  }

  void _printWelcome() {
    _printLine('Welcome to Linux Wizard Academy!');
    _printLine('Type "help" to see available magic spells.');
  }

  void _printLine(String text) {
    output.add(TerminalLine(text: text));
    notifyListeners();
  }

  void _printCommand(String text) {
    output.add(TerminalLine(text: '\$ $text', isCommand: true));
    notifyListeners();
  }

  void processCommand(String command, {bool isDemo = false}) {
    if (currentPhase == 'demonstrate' && activeLesson != null) {
      if (currentStageIndex < activeLesson!.demonstrations.length) {
        String cmd = activeLesson!.demonstrations[currentStageIndex];
        _printLine('Watch closely! Magic spell: \$ $cmd');
        _execute(cmd);
        currentStageIndex++;
        if (currentStageIndex >= activeLesson!.demonstrations.length) {
          currentPhase = 'imitate';
          currentStageIndex = 0;
          _saveProgress(activeLesson!.id, 2);
          _printLine('\n--- IMITATE PHASE ---');
          _promptImitate();
        }
      }
      return;
    }

    if (command.trim().isEmpty) return;

    if (!isDemo) {
      _printCommand(command);
    }

    // Check imitate phase
    if (!isDemo && activeLesson != null && currentPhase == 'imitate') {
      String expected = activeLesson!.imitations[currentStageIndex];
      if (command.trim() == expected) {
        _execute(command);
        _printLine('Great job!');
        currentStageIndex++;
        _promptImitate();
        return;
      } else {
        _printLine('Try again! Type exactly: $expected');
        return;
      }
    }

    // Check practice phase
    if (!isDemo && activeLesson != null && currentPhase == 'practice') {
      RegExp exp = RegExp(activeLesson!.practices[currentStageIndex].expectedCommandPattern);
      if (exp.hasMatch(command.trim())) {
        _execute(command);
        _printLine('Correct! You did it!');
        currentStageIndex++;
        _promptPractice();
        return;
      }
      // If incorrect but valid command, we can let it execute or just tell them it's wrong:
      _execute(command);
      _printLine('That didn\'t seem like the right magic spell for the challenge. Try again!');
      _promptPractice();
      return;
    }

    // Normal execution
    _execute(command);
  }

  void _execute(String command) {
    List<String> parts = command.trim().split(RegExp(r'\s+'));
    String cmd = parts[0];
    List<String> args = parts.sublist(1);

    try {
      switch (cmd) {
        case 'ls':
          _cmdLs(args);
          break;
        case 'cd':
          _cmdCd(args);
          break;
        case 'mkdir':
          _cmdMkdir(args);
          break;
        case 'pwd':
          _cmdPwd(args);
          break;
        case 'touch':
          _cmdTouch(args);
          break;
        case 'rm':
          _cmdRm(args);
          break;
        case 'cat':
          _cmdCat(args);
          break;
        case 'vi':
          _cmdVi(args);
          break;
        case 'clear':
          output.clear();
          notifyListeners();
          break;
        case 'help':
          _printLine('Commands: ls, cd, mkdir, pwd, touch, rm, cat, vi, clear');
          break;
        default:
          _printLine('bash: $cmd: command not found (Wait, is this a made-up spell?)');
      }
    } catch (e) {
      _printLine('Error executing spell: $e');
    }
  }

  void _cmdLs(List<String> args) {
    bool long = args.contains('-l');
    bool all = args.contains('-a');
    var entities = _currentDir.listSync();
    
    if (entities.isEmpty && !all) {
      return;
    }

    List<String> lines = [];
    if (all) {
      lines.add('.  ..');
    }

    for (var entity in entities) {
      String name = p.basename(entity.path);
      if (name.startsWith('.') && !all) continue;
      
      if (long) {
        String type = (entity is Directory) ? 'd' : '-';
        String size = (entity is File) ? entity.lengthSync().toString() : '4096';
        lines.add('${type}rwxr-xr-x 1 wizard wizard $size Jan 1 12:00 $name');
      } else {
        lines.add(name);
      }
    }
    
    if (lines.isNotEmpty) {
      if (long) {
        _printLine(lines.join('\n'));
      } else {
        _printLine(lines.join('  '));
      }
    }
  }

  void _cmdCd(List<String> args) {
    if (args.isEmpty) {
      _currentDir = _homeDir;
      return;
    }
    String target = args[0];
    if (target == '~') {
      _currentDir = _homeDir;
      return;
    }

    String nextPath = p.normalize(p.join(_currentDir.path, target));
    
    // Security: prevent breaking out of home
    if (!nextPath.startsWith(_homeDir.path)) {
      _printLine('bash: cd: $target: Permission denied (You cannot look outside the academy!)');
      return;
    }

    Directory nextDir = Directory(nextPath);
    if (nextDir.existsSync()) {
      _currentDir = nextDir;
    } else {
      _printLine('bash: cd: $target: No such file or directory (This box does not exist!)');
    }
  }

  void _cmdMkdir(List<String> args) {
    if (args.isEmpty) {
      _printLine('mkdir: missing operand (Tell me what to name the new box!)');
      return;
    }
    String targetName = args[0];
    String nextPath = p.normalize(p.join(_currentDir.path, targetName));

    if (!nextPath.startsWith(_homeDir.path)) {
      _printLine('mkdir: cannot create directory: Permission denied');
      return;
    }

    Directory newDir = Directory(nextPath);
    if (!newDir.existsSync()) {
      newDir.createSync();
    } else {
      _printLine('mkdir: cannot create directory \'$targetName\': File exists (A box with this name already exists!)');
    }
  }

  void _cmdPwd(List<String> args) {
    // Show a virtual path relative to home to keep it simple for kids
    String virtualPath = '/home/wizard';
    if (_currentDir.path != _homeDir.path) {
      String rel = p.relative(_currentDir.path, from: _homeDir.path);
      virtualPath = '$virtualPath/$rel';
    }
    _printLine(virtualPath);
    _printLine('''(Real Android Path: ${_currentDir.path})''');
  }

  void _cmdTouch(List<String> args) {
    if (args.isEmpty) {
      _printLine('touch: missing file operand');
      return;
    }
    for (String target in args) {
      String nextPath = p.normalize(p.join(_currentDir.path, target));
      if (!nextPath.startsWith(_homeDir.path)) {
        _printLine('touch: cannot touch \'$target\': Permission denied');
        continue;
      }
      File newFile = File(nextPath);
      if (!newFile.existsSync()) {
        newFile.writeAsStringSync('');
      } else {
        // Just update modified time in a real Linux, here we do nothing
      }
    }
  }

  void _cmdRm(List<String> args) {
    if (args.isEmpty) {
      _printLine('rm: missing operand');
      return;
    }
    for (String target in args) {
      String nextPath = p.normalize(p.join(_currentDir.path, target));
      if (!nextPath.startsWith(_homeDir.path)) {
        _printLine('rm: cannot remove \'$target\': Permission denied');
        continue;
      }
      File file = File(nextPath);
      if (file.existsSync()) {
        file.deleteSync();
      } else {
        _printLine('rm: cannot remove \'$target\': No such file or directory');
      }
    }
  }

  void _cmdCat(List<String> args) {
    if (args.isEmpty) {
      _printLine('cat: missing file operand');
      return;
    }
    for (String target in args) {
      String nextPath = p.normalize(p.join(_currentDir.path, target));
      if (!nextPath.startsWith(_homeDir.path)) {
        _printLine('cat: $target: Permission denied');
        continue;
      }
      File file = File(nextPath);
      if (file.existsSync()) {
        _printLine(file.readAsStringSync());
      } else {
        _printLine('cat: $target: No such file or directory');
      }
    }
  }

  void _cmdVi(List<String> args) {
    if (args.isEmpty) {
      _printLine('vi: missing file operand');
      return;
    }
    String target = args[0];
    String nextPath = p.normalize(p.join(_currentDir.path, target));
    if (!nextPath.startsWith(_homeDir.path)) {
      _printLine('vi: $target: Permission denied');
      return;
    }
    _printLine('(Opening $target in vi...)');
    _printLine('(Simulated: You use \'i\' to insert, write text, and hit ESC, then \':wq\' to save)');
    File file = File(nextPath);
    if (!file.existsSync()) {
      file.writeAsStringSync('');
    }
  }
}
