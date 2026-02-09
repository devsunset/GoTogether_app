import 'package:flutter/material.dart';
import 'package:gotogether/data/di/service_locator.dart';
import 'package:gotogether/data/models/together/together_list_item.dart';
import 'package:gotogether/data/repository/together/together_repository.dart';
import 'package:gotogether/ui/app_theme.dart';
import 'package:gotogether/ui/widgets/screen_helpers.dart';
import 'package:gotogether/ui/together/together_detail_screen.dart';
import 'package:gotogether/ui/together/together_edit_screen.dart';

class TogetherScreen extends StatefulWidget {
  const TogetherScreen({Key? key}) : super(key: key);

  @override
  State<TogetherScreen> createState() => _TogetherScreenState();
}

class _TogetherScreenState extends State<TogetherScreen> {
  final TogetherRepository _repo = getIt<TogetherRepository>();
  final TextEditingController _keywordController = TextEditingController();
  List<TogetherListItem> _list = [];
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
      final page = await _repo.getList(_page, 10, keyword: _keywordController.text.isEmpty ? null : _keywordController.text);
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

  void _goDetail(TogetherListItem item) async {
    final needRefresh = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => TogetherDetailScreen(togetherId: item.togetherId!)),
    );
    if (needRefresh == true) _load();
  }

  void _goNew() async {
    final needRefresh = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const TogetherEditScreen()),
    );
    if (needRefresh == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.notWhite,
      appBar: AppBar(
        title: const Text('Together', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _goNew,
            tooltip: '새 글',
          ),
        ],
      ),
      body: Column(
        children: [
          ModernSearchBar(
            controller: _keywordController,
            hintText: '제목·키워드 검색',
            onSearch: () {
              _page = 0;
              _load();
            },
          ),
          if (_error != null)
            Expanded(
              child: ErrorView(message: _error!, onRetry: () { _page = 0; _load(); }),
            )
          else if (_loading)
            const Expanded(child: LoadingView())
          else
            Expanded(
              child: _list.isEmpty
                  ? const EmptyView(message: '함께할 글이 없습니다.', icon: Icons.group_work_outlined)
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
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.lightText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (item.progress != null) ...[
                                const SizedBox(width: 8),
                                Chip(
                                  label: Text('${item.progress}%', style: const TextStyle(fontSize: 12)),
                                  backgroundColor: _progressColor(item.progressLegend).withOpacity(0.2),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ],
                              const SizedBox(width: 4),
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

  Color _progressColor(String? legend) {
    switch (legend) {
      case 'success': return Colors.green;
      case 'primary': return Colors.blue;
      case 'warning': return Colors.orange;
      default: return Colors.red;
    }
  }
}
