import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

/// 웹 에디터(HTML) 본문을 렌더링하는 위젯.
/// HTML이면 그대로 렌더, 일반 텍스트면 &lt;p&gt;로 감싸서 표시.
class HtmlContentView extends StatelessWidget {
  final String? content;

  const HtmlContentView({Key? key, this.content}) : super(key: key);

  static String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  @override
  Widget build(BuildContext context) {
    final raw = content?.trim() ?? '';
    if (raw.isEmpty) return const SizedBox.shrink();

    final String htmlData = raw.contains('<') && raw.contains('>')
        ? raw
        : '<p>${_escapeHtml(raw)}</p>';

    return Html(
      key: key ?? ValueKey('html_${raw.hashCode}_${raw.length}'),
      data: htmlData,
      shrinkWrap: true,
    );
  }
}
