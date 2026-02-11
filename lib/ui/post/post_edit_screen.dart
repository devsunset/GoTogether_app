import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gotogether/data/di/service_locator.dart';
import 'package:gotogether/data/repository/post/post_repository.dart';
import 'package:gotogether/ui/widgets/html_editor_field.dart';
import 'package:quill_html_editor/quill_html_editor.dart';

/// 유형(category): TALK | QA. 새 글은 [initialCategory]로 고정, 수정 시 기존 category 표시(비활성).
class PostEditScreen extends StatefulWidget {
  final int? postId;
  final Map<String, dynamic>? initialData;
  final String? initialCategory;

  const PostEditScreen({Key? key, this.postId, this.initialData, this.initialCategory}) : super(key: key);

  @override
  State<PostEditScreen> createState() => _PostEditScreenState();
}

class _PostEditScreenState extends State<PostEditScreen> {
  final PostRepository _repo = getIt<PostRepository>();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentEditorController = QuillEditorController();
  String _category = 'TALK';
  bool _saving = false;

  bool get isEdit => widget.postId != null;
  String get _titleLabel => _category == 'QA' ? 'Post Edit Q&A' : 'Post Edit Talk';

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    if (d != null) {
      _titleController.text = d['title']?.toString() ?? '';
      _category = d['category']?.toString() ?? 'TALK';
    } else {
      _category = widget.initialCategory ?? 'TALK';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentEditorController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final contentHtml = (await _contentEditorController.getText()).trim();
    if (contentHtml.isEmpty) {
      Fluttertoast.showToast(msg: '본문을 입력하세요.');
      return;
    }
    setState(() => _saving = true);
    try {
      final data = {
        'title': _titleController.text.trim(),
        'content': contentHtml,
        'category': _category,
      };
      if (isEdit) {
        await _repo.update(widget.postId!, data);
      } else {
        await _repo.create(data);
      }
      Fluttertoast.showToast(msg: '저장되었습니다.');
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titleLabel)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: ['TALK', 'QA'].map((e) => DropdownMenuItem(value: e, child: Text(e == 'TALK' ? 'Talk' : 'Q&A'))).toList(),
              onChanged: isEdit ? null : (v) => setState(() => _category = v ?? 'TALK'),
            ),
            const SizedBox(height: 12),
            const Text('본문 (HTML 에디터)', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            const SizedBox(height: 8),
            HtmlEditorField(
              key: ValueKey('post-edit-${widget.postId ?? "new"}'),
              controller: _contentEditorController,
              initialHtml: widget.initialData?['content']?.toString(),
              hint: '본문을 입력하세요. 서식·링크·이미지 등을 사용할 수 있습니다.',
              height: 320,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_circle_outline, size: 22),
                label: Text(_saving ? '저장 중...' : '저장하기', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }
}
