import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quill_html_editor/quill_html_editor.dart';

/// Together·Post 본문 에디터. Quill 기반.
///
/// **웹**: 패키지(webviewx)가 iframe 첫 로드 시 onPageFinished를 호출하지 않아
/// setText/onEditorCreated가 실행되지 않음. 따라서 onEditorCreated에 의존하지 않고
/// 지연 후 주기적으로 setText를 시도하는 방식으로 초기값을 반드시 설정.
/// **모바일**: onEditorCreated도 사용해 빠르게 설정.
class HtmlEditorField extends StatefulWidget {
  final QuillEditorController controller;
  final String? initialHtml;
  final String hint;
  final double height;

  const HtmlEditorField({
    Key? key,
    required this.controller,
    this.initialHtml,
    this.hint = '내용을 입력하세요...',
    this.height = 320,
  }) : super(key: key);

  @override
  State<HtmlEditorField> createState() => _HtmlEditorFieldState();
}

class _HtmlEditorFieldState extends State<HtmlEditorField> {
  bool _hasSetInitialText = false;
  bool _editorReady = false; // 로딩 숨김: 초기값 설정 완료 또는 초기값 없음일 때
  Timer? _pollTimer;
  Timer? _readyTimer;
  static const int _maxAttempts = 28;
  static const Duration _pollInterval = Duration(milliseconds: 600);
  static const Duration _startDelay = Duration(milliseconds: 1200);
  static const Duration _afterSetDelay = Duration(milliseconds: 350);

  String? get _html => widget.initialHtml?.trim();
  bool get _hasInitial => _html != null && _html!.isNotEmpty;

  void _startPolling() {
    if (!_hasInitial || _hasSetInitialText) return;
    _pollTimer?.cancel();
    int attempt = 0;
    _pollTimer = Timer.periodic(_pollInterval, (timer) async {
      if (!mounted || _hasSetInitialText || attempt >= _maxAttempts) {
        timer.cancel();
        _pollTimer = null;
        return;
      }
      final html = _html;
      if (html == null || html.isEmpty) {
        timer.cancel();
        _pollTimer = null;
        return;
      }
      attempt++;
      try {
        await widget.controller.setText(html);
        await Future.delayed(_afterSetDelay);
        if (!mounted) return;
        final current = (await widget.controller.getText()).trim();
        final ok = current.isNotEmpty &&
            (current.length >= html.length ~/ 2 ||
                current.contains(RegExp(r'<[^>]+>')) ||
                current.length > 8);
        if (ok && mounted) {
          _hasSetInitialText = true;
          _editorReady = true;
          timer.cancel();
          _pollTimer = null;
          setState(() {});
          return;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('HtmlEditorField setText attempt $attempt/$_maxAttempts: $e');
        }
      }
    });
  }

  void _scheduleStart() {
    if (!_hasInitial) return;
    Future.delayed(_startDelay, () {
      if (mounted && !_hasSetInitialText) _startPolling();
    });
  }

  @override
  void initState() {
    super.initState();
    // 초기값 없을 때(새 글): 일정 시간 후 로딩 숨김 (웹에서 패키지 onPageFinished 미호출 대응)
    if (!_hasInitial) {
      _readyTimer = Timer(const Duration(milliseconds: 2200), () {
        if (mounted && !_editorReady) {
          setState(() => _editorReady = true);
        }
      });
    }
    _scheduleStart();
    widget.controller.onEditorLoaded(() {
      if (mounted && _hasInitial && !_hasSetInitialText) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 80), () {
            if (mounted && !_hasSetInitialText) _startPolling();
          });
        });
      } else if (mounted && !_hasInitial) {
        _editorReady = true;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _readyTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant HtmlEditorField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialHtml != widget.initialHtml &&
        (widget.initialHtml?.trim().isNotEmpty == true)) {
      _hasSetInitialText = false;
      _editorReady = false;
      _pollTimer?.cancel();
      _readyTimer?.cancel();
      _scheduleStart();
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialHtml = widget.initialHtml?.trim() ?? '';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ToolBar.scroll(
          toolBarColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade800
              : Colors.grey.shade100,
          activeIconColor: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          iconSize: 20,
          controller: widget.controller,
          direction: Axis.horizontal,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: widget.height,
          child: QuillHtmlEditor(
            text: initialHtml,
            hintText: widget.hint,
            controller: widget.controller,
            isEnabled: true,
            minHeight: widget.height,
            textStyle: const TextStyle(fontSize: 16, color: Colors.black87),
            hintTextStyle: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            hintTextAlign: TextAlign.start,
            padding: const EdgeInsets.all(12),
            hintTextPadding: EdgeInsets.zero,
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade900
                : Colors.white,
            // 값 설정 완료(_editorReady)되면 로딩 숨김. 웹에서 패키지 onPageFinished 미호출 시 스피너 계속 도는 문제 대응.
            loadingBuilder: (context) => _editorReady
                ? const SizedBox.shrink()
                : const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
            onEditorCreated: () {
              if (_hasInitial && !_hasSetInitialText) _startPolling();
            },
          ),
        ),
      ],
    );
  }
}
