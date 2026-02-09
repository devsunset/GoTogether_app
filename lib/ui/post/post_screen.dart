import 'package:flutter/material.dart';
import 'package:gotogether/data/di/service_locator.dart';
import 'package:gotogether/data/models/post/post_list_item.dart';
import 'package:gotogether/data/repository/post/post_repository.dart';
import 'package:gotogether/ui/app_theme.dart';
import 'package:gotogether/ui/post/post_detail_screen.dart';
import 'package:gotogether/ui/post/post_edit_screen.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final PostRepository _repo = getIt<PostRepository>();
  final TextEditingController _keywordController = TextEditingController();
  List<PostListItem> _list = [];
  int _page = 0;
  int _totalPages = 0;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
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
      final page = await _repo.getList(_page, 10,
          keyword: _keywordController.text.isEmpty ? null : _keywordController.text);
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
    final needRefresh = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => PostDetailScreen(postId: item.postId!)),
    );
    if (needRefresh == true) _load();
  }

  void _goNew() async {
    final needRefresh = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const PostEditScreen()),
    );
    if (needRefresh == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.nearlyWhite,
      appBar: AppBar(
        title: const Text('Post'),
        backgroundColor: AppTheme.nearlyWhite,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _goNew),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _keywordController,
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onSubmitted: (_) {
                      _page = 0;
                      _load();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _page = 0;
                    _load();
                  },
                  child: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: _list.isEmpty
                  ? const Center(child: Text('No Data.'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _list.length + (_totalPages > 1 ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _list.length) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_page > 0)
                                  TextButton(
                                    onPressed: () {
                                      _page--;
                                      _load();
                                    },
                                    child: const Text('Prev'),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text('${_page + 1} / $_totalPages'),
                                ),
                                if (_page < _totalPages - 1)
                                  TextButton(
                                    onPressed: () {
                                      _page++;
                                      _load();
                                    },
                                    child: const Text('Next'),
                                  ),
                              ],
                            ),
                          );
                        }
                        final item = _list[index];
                        final dateStr = item.createdDate ?? '';
                        final shortDate = dateStr.length > 16 ? dateStr.substring(0, 16) : dateStr;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(item.title ?? ''),
                            subtitle: Text('${item.nickname ?? ''} · $shortDate'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _goDetail(item),
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
