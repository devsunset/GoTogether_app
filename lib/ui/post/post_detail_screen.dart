/// Post 상세·댓글·수정/삭제. Admin일 때만 "Category 변경" 버튼 표시. Vue post detail과 동일.
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gotogether/data/di/service_locator.dart';
import 'package:gotogether/data/repository/post/post_repository.dart';
import 'package:gotogether/ui/app_theme.dart';
import 'package:gotogether/ui/post/post_edit_screen.dart';
import 'package:gotogether/ui/widgets/html_content_view.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;

  const PostDetailScreen({Key? key, required this.postId}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final PostRepository _repo = getIt<PostRepository>();
  Map<String, dynamic>? _data;
  List<dynamic> _comments = [];
  bool _loading = true;
  String? _error;
  final TextEditingController _commentController = TextEditingController();
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _load();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final storage = const FlutterSecureStorage();
    final role = await storage.read(key: 'ROLE');
    if (mounted) setState(() => _isAdmin = role == 'ROLE_ADMIN');
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _repo.get(widget.postId);
      final comments = await _repo.getCommentList(widget.postId);
      setState(() {
        _data = res.data;
        _comments = comments;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    try {
      await _repo.createComment({'postId': widget.postId, 'content': text});
      _commentController.clear();
      _load();
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> _edit() async {
    final needRefresh = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PostEditScreen(postId: widget.postId, initialData: _data),
      ),
    );
    if (needRefresh == true) _load();
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete'),
        content: const Text('Delete this Post?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _repo.delete(widget.postId);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  /// Vue와 동일: Admin용 Post 유형(TALK↔QA) 변경
  Future<void> _changeCategory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Category 변경'),
        content: const Text('Category를 변경 하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('확인')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _repo.changeCategory(widget.postId);
      Fluttertoast.showToast(msg: '변경되었습니다.');
      if (mounted) _load();
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Post')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Post')),
        body: Center(child: Text(_error!)),
      );
    }
    final d = _data ?? {};
    final postId = widget.postId;
    final String categoryLabel = d['category']?.toString() == 'QA' ? 'Post Detail Q&A' : 'Post Detail Talk';
    return Scaffold(
      key: ValueKey('post_detail_scaffold_$postId'),
      backgroundColor: AppTheme.nearlyWhite,
      appBar: AppBar(
        title: Text(categoryLabel),
        backgroundColor: AppTheme.nearlyWhite,
        elevation: 0,
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              onPressed: _changeCategory,
              tooltip: 'Category 변경',
            ),
          IconButton(icon: const Icon(Icons.edit), onPressed: _edit),
          IconButton(icon: const Icon(Icons.delete), onPressed: _delete),
        ],
      ),
      body: RepaintBoundary(
        child: KeyedSubtree(
          key: ValueKey('post_detail_body_$postId'),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d['title']?.toString() ?? '',
                  style: Theme.of(context).textTheme.headline6,
                ),
                const SizedBox(height: 8),
                Text('${d['nickname'] ?? ''} · ${d['createdDate'] ?? ''}'),
                const Divider(),
                HtmlContentView(key: ValueKey('html_content_$postId'), content: d['content']?.toString()),
                const SizedBox(height: 16),
                const Text('Comments', style: TextStyle(fontWeight: FontWeight.bold)),
                ...List.generate(_comments.length, (i) {
                  final c = _comments[i];
                  final map = c is Map ? c : {};
                  return ListTile(
                    key: ValueKey('comment_${postId}_$i'),
                    title: HtmlContentView(key: ValueKey('comment_html_${postId}_$i'), content: map['content']?.toString()),
                    subtitle: Text(map['nickname']?.toString() ?? ''),
                  );
                }),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: 'Write a comment',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.send), onPressed: _addComment),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
