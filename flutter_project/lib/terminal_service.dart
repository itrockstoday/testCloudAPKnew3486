import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:xterm/xterm.dart';

class TerminalService extends ChangeNotifier {
  late final Terminal terminal;
  late final Pty pty;
  final TerminalController terminalController = TerminalController();

  TerminalService() {
    terminal = Terminal(maxLines: 10000);
    _initializePty();
  }

  void _initializePty() {
    // Connect to native Android shell
    pty = Pty.start(
      '/system/bin/sh',
      columns: terminal.viewWidth,
      rows: terminal.viewHeight,
      environment: {
        'TERM': 'xterm-256color',
        'HOME': '/data/user/0/com.example.linux_wizard/files',
      },
    );

    pty.output
        .transform(utf8.decoder)
        .listen((data) => terminal.write(data));

    terminal.onOutput = (data) {
      pty.write(utf8.encode(data));
    };
  }

  void writeCommand(String command) {
    terminal.write('\r\n$command\r\n');
    pty.write(utf8.encode('$command\n'));
  }

  @override
  void dispose() {
    pty.terminate();
    super.dispose();
  }
}
