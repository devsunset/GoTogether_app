import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gotogether/data/di/service_locator.dart';
import 'package:gotogether/data/models/post/post_list_item.dart';
import 'package:gotogether/data/repository/post/post_repository.dart';
import 'package:gotogether/ui/app_theme.dart';
import 'package:gotogether/ui/widgets/screen_helpers.dart';
import 'package:gotogether/ui/post/post_detail_screen.dart';
import 'package:gotogether/ui/post/post_edit_screen.dart';

/// 유형(category): TALK | QA. Vue와 동일하게 분기.
class PostScreen extends StatefulWidget {
  final String category;

  const PostScreen({Key? key, this.category = 'TALK'}) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final PostRepository _repo = getIt<PostRepository>();
  static const _storage = FlutterSecureStorage();
  final TextEditingController _keywordController = TextEditingController();
  List<PostListItem> _list = [];
  int _page = 0;
  int _totalPages = 0;
  bool _loading = false;
  String? _error;
  late String _category;
  Future<bool> get _isLoggedIn async {
    final nickname = await _storage.read(key: 'NICK_NAME');
    return nickname != null && nickname.isNotEmpty && nickname != 'Anonymous';
  }

  static const List<String> _categoryCodes = ['TALK', 'QA'];
  String get _titleLabel => _category == 'QA' ? 'Post Q&A' : 'Post Talk';

  @override
  void initState() {
    super.initState();
    _category = widget.category;
    _load();
  }

  @override
  void didUpdateWidget(PostScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category) {
      _category = widget.category;
      _page = 0;
      _load();
    }
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await _repo.getList(
        _page,
        10,
        category: _category,
        keyword: _keywordController.text.isEmpty ? null : _keywordController.text,
      );
      setState(() {
        _list = page.content;
        _totalPages = page.totalPages;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _goDetail(PostListItem item) async {
    if (!mounted) return;
    final needRefresh = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(key: ValueKey('detail_${item.postId}'), postId: item.postId!),
        settings: RouteSettings(name: '/post/${item.postId}'),
        fullscreenDialog: true,
      ),
    );
    if (mounted && needRefresh == true) _load();
  }

  void _goNew() async {
    if (!mounted) return;
    final needRefresh = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PostEditScreen(initialCategory: _category),
      ),
    );
    if (mounted && needRefresh == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.notWhite,
      appBar: AppBar(
        title: Text(_titleLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 2,
        actions: [
          FutureBuilder<bool>(
            future: _isLoggedIn,
            builder: (context, snap) {
              if (snap.data == true) {
                return IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _goNew,
                  tooltip: '새 글',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: DropdownButtonFormField<String>(
                    value: _category,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                    items: _categoryCodes
                        .map((e) => DropdownMenuItem(value: e, child: Text(e == 'TALK' ? 'Talk' : 'Q&A')))
                        .toList(),
                    onChanged: (v) {
                      if (v != null && v != _category) {
                        setState(() {
                          _category = v;
                          _page = 0;
                        });
                        _load();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: ModernSearchBar(
                  controller: _keywordController,
                  hintText: '제목·키워드 검색',
                  onSearch: () {
                    _page = 0;
                    _load();
                  },
                )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (_error != null)
            Expanded(
              child: ErrorView(message: _error!, onRetry: () { _page = 0; _load(); }),
            )
          else if (_loading)
            const Expanded(child: LoadingView())
          else
            Expanded(
              child: _list.isEmpty
                  ? const EmptyView(message: '게시글이 없습니다.', icon: Icons.article_outlined)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _list.length + (_totalPages > 1 ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _list.length) {
                          return PaginationBar(
                            page: _page,
                            totalPages: _totalPages,
                            onPrev: _page > 0 ? () { _page--; _load(); } : null,
                            onNext: _page < _totalPages - 1 ? () { _page++; _load(); } : null,
                          );
                        }
                        final item = _list[index];
                        final dateStr = item.createdDate ?? '';
                        final shortDate = dateStr.length > 16 ? dateStr.substring(0, 16) : dateStr;
                        return ModernListCard(
                          onTap: () => _goDetail(item),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: AppTheme.darkerText,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${item.nickname ?? ''} · $shortDate',
                                      style: const TextStyle(fontSize: 13, color: AppTheme.lightText),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.chat_bubble_outline, size: 14, color: AppTheme.lightText),
                                        const SizedBox(width: 4),
                                        Text('${item.comment_count ?? 0}', style: const TextStyle(fontSize: 12, color: AppTheme.lightText)),
                                        const SizedBox(width: 12),
                                        Icon(Icons.visibility_outlined, size: 14, color: AppTheme.lightText),
                                        const SizedBox(width: 4),
                                        Text('${item.hit ?? 0}', style: const TextStyle(fontSize: 12, color: AppTheme.lightText)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: AppTheme.lightText),
                            ],
                          ),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}
