import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../engine/terminal_engine.dart';

class TerminalScreen extends StatelessWidget {
  final String prompt;
  final String target;
  final EDIPStage stage;

  TerminalScreen({required this.prompt, required this.target, required this.stage});

  @override
  Widget build(BuildContext context) {
    final engine = Provider.of<TerminalEngine>(context);
    final controller = TextEditingController();

    return Column(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(24),
            ),
            child: ListView.builder(
              itemCount: engine.history.length,
              itemBuilder: (context, index) {
                final line = engine.history[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text(line['type'] == 'user' ? "➜ " : "✨ ", 
                        style: GoogleFonts.jetbrainsMono(color: Colors.indigoAccent)),
                      Expanded(
                        child: Text(line['text'] ?? "", 
                          style: GoogleFonts.jetbrainsMono(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.jetbrainsMono(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Cast your spell...",
              hintStyle: TextStyle(color: Colors.white24),
              border: InputBorder.none,
            ),
            onSubmitted: (value) {
              engine.execute(value, target, stage);
              controller.clear();
            },
          ),
        ),
      ],
    );
  }
}
