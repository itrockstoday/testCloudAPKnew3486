import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../engine/terminal_engine.dart';

class TerminalScreen extends StatefulWidget {
  const TerminalScreen({super.key});

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  void _submitCommand(String command) {
    if (command.isEmpty) return;
    _controller.clear();
    Provider.of<TerminalEngine>(context, listen: false).processCommand(command);
    _scrollToBottom();
    _focusNode.requestFocus();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Magic Terminal'),
        backgroundColor: Colors.grey[900],
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text('Exit & Save', style: TextStyle(color: Colors.white)),
            onPressed: () {
              // Engine already saves state automatically on each step.
              // Just wipe active lesson so we're clean and pop.
              Provider.of<TerminalEngine>(context, listen: false).activeLesson = null;
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Consumer<TerminalEngine>(
        builder: (context, engine, child) {
          int count = engine.output.length;
          _scrollToBottom(); // scroll on new output
          return Column(
            children: [
              // Lesson HUD if active
              if (engine.activeLesson != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[900],
                    border: const Border(bottom: BorderSide(color: Colors.blueGrey, width: 2)),
                  ),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✨ ${engine.activeLesson!.title} (${engine.currentPhase.toUpperCase()}) ✨',
                        style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        engine.currentInstruction,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              // Terminal Output
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: count,
                  itemBuilder: (context, index) {
                    final line = engine.output[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        line.text,
                        style: TextStyle(
                          color: line.isCommand ? Colors.greenAccent : Colors.white70,
                          fontFamily: 'monospace',
                          fontSize: 16,
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Input area
              Container(
                color: Colors.grey[900],
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    const Text(
                      '\$ ',
                      style: TextStyle(color: Colors.greenAccent, fontFamily: 'monospace', fontSize: 18),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 18),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: engine.currentPhase == 'demonstrate' ? 'Press any keyboard button...' : 'Type your magic spell...',
                          hintStyle: const TextStyle(color: Colors.white30),
                        ),
                        onChanged: (val) {
                          if (engine.currentPhase == 'demonstrate') {
                            _controller.clear();
                            engine.processCommand('');
                            _scrollToBottom();
                          }
                        },
                        onSubmitted: (val) {
                          if (engine.currentPhase == 'demonstrate') {
                            _controller.clear();
                            engine.processCommand('');
                            _scrollToBottom();
                            // Keep keyboard open
                            _focusNode.requestFocus();
                            return;
                          }
                          _submitCommand(val);
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.greenAccent),
                      onPressed: () {
                          if (engine.currentPhase == 'demonstrate') {
                            engine.processCommand('');
                            _scrollToBottom();
                          } else {
                            _submitCommand(_controller.text);
                          }
                      },
                    )
                  ],
                ),
              ),
              if (engine.currentPhase == 'demonstrate')
                 Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: ElevatedButton(
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.indigo,
                       foregroundColor: Colors.white,
                       minimumSize: const Size(double.infinity, 48),
                     ),
                     onPressed: () {
                        engine.processCommand('');
                        _scrollToBottom();
                     },
                     child: const Text('Press Here or Enter to Continue'),
                   ),
                 ),
            ],
          );
        },
      ),
    );
  }
}
