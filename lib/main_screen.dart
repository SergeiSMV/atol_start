// ignore_for_file: type_literal_in_constant_pattern

import 'dart:async';

import 'package:atol_start/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import 'main_screen_widget.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({
    super.key,
    this.onChanged,
    this.onNotFound,
    // this.child,
    this.getFocusNode,
    this.autoFocus = true,
  });

  ///listen barcode change
  final ValueChanged<String>? onChanged;

  ///listen barcode not found
  final VoidCallback? onNotFound;

  ///limit use of TextField
  // final Widget? child;

  ///get focus node to handle from external
  final Function(FocusNode focusNode)? getFocusNode;

  final bool autoFocus;

  @override
  ConsumerState<MainScreen> createState() => _MainScreen();
}

class _MainScreen extends ConsumerState <MainScreen> {
  static const String _notFound = '404_PDA_SCAN_NOT_FOUND';
  static const String _startScanLabelKey = 'F12';
  static const String _endScanLabelKey = 'ENTER';
  final BehaviorSubject<String> _subject = BehaviorSubject();
  late final StreamSubscription _streamSubscription;
  final FocusNode _focusNode = FocusNode();
  final StringBuffer _chars = StringBuffer();
  bool packMode = true;

  @override
  void initState() {
    super.initState();
    widget.getFocusNode?.call(_focusNode);
    
    _streamSubscription = _subject.stream.debounceTime(const Duration(milliseconds: 50)).listen((code) {
      if (code == _notFound) {
        widget.onNotFound?.call();
      } else {
        widget.onChanged?.call(code);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    _subject.close();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: (KeyEvent event) {
          switch (event.runtimeType) {
            case KeyDownEvent:
              {
                if (event.logicalKey.keyLabel.length == 1) {
                  if (event.character?.isNotEmpty ?? false) {
                    _chars.write(event.character![0]);
                  } else {
                    _chars.write(event.logicalKey.keyLabel.characters.first);
                  }
                  _subject.add(_chars.toString());
                }
                return;
              }
            case KeyUpEvent:
              {
                switch (event.logicalKey.keyLabel.toUpperCase()) {
                  case _startScanLabelKey:
                    {
                      _subject.add(_notFound);
                      return;
                    }
                  case _endScanLabelKey:
                    {
                      ref.read(scanProvider.notifier).state = _chars.toString();
                      _chars.clear();
                      return;
                    }
                }
              }
          }
        },
        child: mainScreenWidget()
      )
    );
  }
}