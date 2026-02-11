import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quill_html_editor/quill_html_editor.dart';

/// Together·Post 본문 에디터. Quill 기반으로 웹/모바일 모두 안정 동작.
/// 수정 진입 시 기존 값: onEditorCreated 한 경로로만 setText하고, 패키지가 로딩 오버레이를
/// 먼저 숨긴 뒤(지연) setText 해서 프로그레스가 사라지고 초기값도 안정 적용되도록 함.
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
  static const Duration _delayBeforeSetText = Duration(milliseconds: 280);
  static const Duration _retryDelay = Duration(milliseconds: 250);
  static const int _maxRetries = 2;

  /// 에디터 준비 후 한 번만 setText. 실패 시 한두 번 재시도.
  Future<void> _applyInitialHtmlOnce({int retryCount = 0}) async {
    if (_hasSetInitialText) return;
    final html = widget.initialHtml?.trim();
    if (html == null || html.isEmpty) return;
    if (!mounted) return;

    try {
      await widget.controller.setText(html);
      if (mounted) setState(() => _hasSetInitialText = true);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('HtmlEditorField: setText failed (${retryCount + 1}/$_maxRetries): $e');
      }
      if (mounted && retryCount < _maxRetries - 1) {
        await Future.delayed(_retryDelay);
        if (mounted) _applyInitialHtmlOnce(retryCount: retryCount + 1);
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant HtmlEditorField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialHtml != widget.initialHtml &&
        widget.initialHtml?.trim().isNotEmpty == true) {
      _hasSetInitialText = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) _applyInitialHtmlOnce();
        });
      });
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
            loadingBuilder: (context) => const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            onEditorCreated: () {
              // 패키지가 먼저 _editorLoaded=true·setState 해서 로딩 오버레이가 사라지도록
              // 콜백은 기다리지 않고, 지연 후 setText만 실행.
              Future.delayed(_delayBeforeSetText, () {
                if (mounted) _applyInitialHtmlOnce();
              });
            },
          ),
        ),
      ],
    );
  }
}
