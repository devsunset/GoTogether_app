import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quill_html_editor/quill_html_editor.dart';

/// Together·Post 본문 에디터. Quill 기반으로 웹/모바일 모두 안정 동작.
/// 수정 진입 시 initialHtml이 웹에서 적용되지 않는 문제를 위해,
/// 웹에서는 onEditorCreated 후 지연 setText 폴백을 사용합니다.
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

  /// React 패턴 참고: 에디터가 완전히 로드된 후 setText 호출 (웹에서 안정적)
  Future<void> _setInitialTextIfNeeded() async {
    if (_hasSetInitialText) return;
    final html = widget.initialHtml?.trim();
    if (html == null || html.isEmpty) return;

    try {
      await widget.controller.setText(html);
      if (mounted) {
        _hasSetInitialText = true;
      }
    } catch (e) {
      // 에디터가 아직 준비되지 않았을 수 있음 - 재시도는 onEditorLoaded에서
      if (kDebugMode) {
        debugPrint('HtmlEditorField: setText failed, will retry: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // React useEffect 패턴: 첫 프레임 후 setText 시도
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.initialHtml?.trim().isNotEmpty == true) {
        _setInitialTextIfNeeded();
      }
    });
    // React 패턴: onEditorLoaded 콜백에서 setText (가장 확실한 방법)
    widget.controller.onEditorLoaded(() {
      if (mounted && widget.initialHtml?.trim().isNotEmpty == true) {
        _hasSetInitialText = false; // 재설정 허용
        _setInitialTextIfNeeded();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // initialHtml이 변경될 때도 재설정 (React의 dependency array와 유사)
    if (widget.initialHtml?.trim().isNotEmpty == true) {
      _hasSetInitialText = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _setInitialTextIfNeeded();
        }
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
