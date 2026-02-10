/// Post(Talk/Q&A) 상세: 글 정보·내용·댓글·댓글 작성 영역 구분.
/// Admin일 때만 Category 변경, 작성자/Admin만 수정·삭제.
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gotogether/data/di/service_locator.dart';
import 'package:gotogether/data/repository/post/post_repository.dart';
import 'package:gotogether/ui/app_theme.dart';
import 'package:gotogether/ui/post/post_edit_screen.dart';
import 'package:gotogether/ui/widgets/html_content_view.dart';
import 'package:gotogether/ui/widgets/screen_helpers.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;

  const PostDetailScreen({Key? key, required this.postId}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final PostRepository _repo = getIt<PostRepository>();
  static const _storage = FlutterSecureStorage();
  Map<String, dynamic>? _data;
  List<dynamic> _comments = [];
  bool _loading = true;
  String? _error;
  String? _currentUsername;
  String? _currentRole;
  final TextEditingController _commentController = TextEditingController();
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  bool get _canEditDelete {
    if (_data == null) return false;
    final writerUsername = _data!['username']?.toString();
    return _currentUsername != null &&
        (writerUsername == _currentUsername || _currentRole == 'ROLE_ADMIN');
  }

  bool _canDeleteComment(dynamic comment) {
    final map = comment is Map ? comment : {};
    final commentUsername = map['username']?.toString();
    return _currentUsername != null &&
        (commentUsername == _currentUsername || _currentRole == 'ROLE_ADMIN');
  }

  Future<void> _deleteComment(int commentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('삭제'),
        content: const Text('이 댓글을 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('삭제')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _repo.deleteComment(commentId);
      _load();
      Fluttertoast.showToast(msg: '삭제되었습니다.');
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
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
      _currentUsername = await _storage.read(key: 'USER_NAME');
      _currentRole = await _storage.read(key: 'ROLE');
      _isAdmin = _currentRole == 'ROLE_ADMIN';
      final res = await _repo.get(widget.postId);
      final comments = await _repo.getCommentList(widget.postId);
      if (mounted) {
        setState(() {
          _data = res.data;
          _comments = comments;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      Fluttertoast.showToast(msg: 'Comment 내용을 입력해 주세요.');
      return;
    }
    try {
      await _repo.createComment({'postId': widget.postId, 'content': text});
      _commentController.clear();
      _load();
      Fluttertoast.showToast(msg: '저장되었습니다.');
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
          if (_canEditDelete) ...[
            IconButton(icon: const Icon(Icons.edit), onPressed: _edit, tooltip: '수정'),
            IconButton(icon: const Icon(Icons.delete), onPressed: _delete, tooltip: '삭제'),
          ],
        ],
      ),
      body: RepaintBoundary(
        child: KeyedSubtree(
          key: ValueKey('post_detail_body_$postId'),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.paddingScreen),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                const SizedBox(height: 8),
                DetailSection(
                  title: '글 정보',
                  icon: Icons.article_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d['title']?.toString() ?? '',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.darkerText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.visibility_outlined, size: 16, color: AppTheme.lightText),
                          const SizedBox(width: 4),
                          Text('${d['hit'] ?? 0}', style: const TextStyle(fontSize: 13, color: AppTheme.lightText)),
                          const SizedBox(width: 16),
                          Icon(Icons.chat_bubble_outline, size: 16, color: AppTheme.lightText),
                          const SizedBox(width: 4),
                          Text('${_comments.length}', style: const TextStyle(fontSize: 13, color: AppTheme.lightText)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${d['nickname'] ?? ''} · ${d['modifiedDate'] ?? d['createdDate'] ?? ''}',
                        style: const TextStyle(fontSize: 13, color: AppTheme.lightText),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                DetailSection(
                  title: '내용',
                  icon: Icons.description_outlined,
                  padding: const EdgeInsets.all(AppTheme.paddingCard),
                  child: HtmlContentView(key: ValueKey('html_content_$postId'), content: d['content']?.toString()),
                ),
                const SizedBox(height: 20),
                DetailSection(
                  title: '댓글 (${_comments.length})',
                  icon: Icons.chat_bubble_outline,
                  child: _comments.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text('아직 댓글이 없습니다.', style: TextStyle(color: AppTheme.lightText, fontSize: 14)),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(_comments.length, (i) {
                            final c = _comments[i];
                            final map = c is Map ? c : {};
                            final rawId = map['postCommentId'] ?? map['id'];
                            final intId = rawId == null ? null : (rawId is int ? rawId : (rawId is num ? rawId.toInt() : int.tryParse(rawId.toString())));
                            return Column(
                              key: ValueKey('comment_${postId}_$i'),
                              children: [
                                if (i > 0) const Divider(height: 24),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(map['nickname']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.darkerText)),
                                          const SizedBox(height: 4),
                                          Text(map['modifiedDate']?.toString() ?? map['createdDate']?.toString() ?? '', style: const TextStyle(fontSize: 12, color: AppTheme.lightText)),
                                          const SizedBox(height: 8),
                                          Text(map['content']?.toString() ?? '', style: const TextStyle(fontSize: 14), maxLines: 20, overflow: TextOverflow.ellipsis),
                                        ],
                                      ),
                                    ),
                                    if (_canDeleteComment(c) && intId != null && intId > 0)
                                      IconButton(
                                        icon: const Icon(Icons.close, size: 20),
                                        onPressed: () => _deleteComment(intId),
                                        tooltip: '댓글 삭제',
                                      ),
                                  ],
                                ),
                              ],
                            );
                          }),
                        ),
                ),
                const SizedBox(height: 20),
                if (_currentUsername != null && _currentUsername!.isNotEmpty)
                  DetailSection(
                    title: '댓글 작성',
                    icon: Icons.reply_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextField(
                          controller: _commentController,
                          maxLines: 5,
                          maxLength: 1000,
                          decoration: const InputDecoration(
                            hintText: 'Comment를 남겨 보세요.',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _addComment,
                          child: const Text('등록'),
                        ),
                      ],
                    ),
                  )
                else
                  DetailSection(
                    title: '댓글 작성',
                    icon: Icons.reply_outlined,
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppTheme.primary, size: 24),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            '로그인을 하시면 댓글 작성이 가능합니다.',
                            style: TextStyle(color: AppTheme.darkText, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
