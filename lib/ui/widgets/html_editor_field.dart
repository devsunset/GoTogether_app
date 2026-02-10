import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quill_html_editor/quill_html_editor.dart';

/// Together·Post 본문 에디터. Quill 기반으로 웹/모바일 모두 안정 동작.
/// 수정 진입 시 기존 값 셋팅: React(Togetheredit/Postedit)처럼 에디터가 완전히 로드된 뒤
/// setText로 HTML을 넣고, 실패 시 짧은 지연 후 재시도합니다.
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
  static const int _maxRetries = 4;
  static const Duration _retryDelay = Duration(milliseconds: 150);

  /// React 패턴(quill.clipboard.dangerouslyPasteHTML): 에디터 로드 후 setText 호출.
  /// 실패 시 짧은 지연 후 재시도하여 웹/모바일 모두 초기값이 안정적으로 셋팅되도록 함.
  Future<void> _setInitialTextIfNeeded({int retryCount = 0}) async {
    if (_hasSetInitialText) return;
    final html = widget.initialHtml?.trim();
    if (html == null || html.isEmpty) return;
    if (!mounted) return;

    try {
      await widget.controller.setText(html);
      if (mounted) {
        setState(() => _hasSetInitialText = true);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('HtmlEditorField: setText failed (attempt ${retryCount + 1}/$_maxRetries): $e');
      }
      if (mounted && retryCount < _maxRetries - 1) {
        await Future.delayed(_retryDelay);
        if (mounted) _setInitialTextIfNeeded(retryCount: retryCount + 1);
      }
    }
  }

  void _scheduleSetInitial() {
    if (widget.initialHtml?.trim().isEmpty != false) return;
    _hasSetInitialText = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _setInitialTextIfNeeded();
    });
  }

  @override
  void initState() {
    super.initState();
    // React useEffect([quill]) 패턴: 에디터 준비 후 한 번 setText. onEditorLoaded는
    // 패키지에서 editor 로드 시 한 번만 emit하므로, 등록만 해 두면 로드 완료 시 호출됨.
    widget.controller.onEditorLoaded(() {
      if (mounted && widget.initialHtml?.trim().isNotEmpty == true) {
        _setInitialTextIfNeeded();
      }
    });
    _scheduleSetInitial();
  }

  @override
  void didUpdateWidget(covariant HtmlEditorField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // initialHtml이 나중에 들어온 경우(예: 상세 데이터 비동기 로드 후 수정 진입)
    if (oldWidget.initialHtml != widget.initialHtml &&
        widget.initialHtml?.trim().isNotEmpty == true) {
      _scheduleSetInitial();
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
            onEditorCreated: () async {
              // React 패턴: onEditorCreated에서도 setText 시도
              await _setInitialTextIfNeeded();
            },
          ),
        ),
      ],
    );
  }
}
