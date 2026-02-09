import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';

/// Together·Post 본문 에디터. Vue와 동일하게 웹/모바일 모두 HtmlEditor 사용.
class HtmlEditorField extends StatelessWidget {
  final HtmlEditorController controller;
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
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: HtmlEditor(
        controller: controller,
        htmlEditorOptions: HtmlEditorOptions(
          hint: hint,
          initialText: initialHtml?.trim() ?? '',
          darkMode: false,
          shouldEnsureVisible: true,
        ),
        htmlToolbarOptions: HtmlToolbarOptions(
          toolbarPosition: ToolbarPosition.aboveEditor,
          toolbarType: ToolbarType.nativeScrollable,
        ),
        otherOptions: OtherOptions(
          height: height,
        ),
      ),
    );
  }
}
