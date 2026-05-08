import 'package:flutter/foundation.dart';

enum EDIPStage { explain, demonstrate, imitate, practice }

class TerminalEngine extends ChangeNotifier {
  List<Map<String, String>> history = [];
  String currentPath = "/home/wizard";
  Map<String, List<String>> fileSystem = {
    "/home/wizard": ["magic_box", "secret_club"],
    "/home/wizard/magic_box": ["wand", "crystal"],
  };

  void execute(String input, String target, EDIPStage stage) {
    history.add({"type": "user", "text": input});

    if (stage == EDIPStage.imitate || stage == EDIPStage.practice) {
      if (input.trim() == target.trim()) {
        history.add({"type": "success", "text": "✨ Magic Success! You did it!"});
      } else {
        history.add({"type": "error", "text": "❌ The spell failed. Try again!"});
      }
    } else {
      // Basic mock output for free-play
      if (input == "ls") {
        history.add({"type": "output", "text": fileSystem[currentPath]?.join("  ") ?? ""});
      } else if (input == "pwd") {
        history.add({"type": "output", "text": currentPath});
      } else {
        history.add({"type": "output", "text": "Command hidden in this stage!"});
      }
    }
    notifyListeners();
  }

  void clear() {
    history.clear();
    notifyListeners();
  }
}
