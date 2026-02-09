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
    if (!mounted) return;
    final needRefresh = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TogetherDetailScreen(key: ValueKey('detail_${item.togetherId}'), togetherId: item.togetherId!),
        settings: RouteSettings(name: '/together/${item.togetherId}'),
        fullscreenDialog: true,
      ),
    );
    if (mounted && needRefresh == true) _load();
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
                                _ProgressBadge(
                                  progress: item.progress!,
                                  legend: item.progressLegend,
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

}

/// 달성률(%) 표시용 뱃지. 원색 대신 테마에 맞는 부드러운 색상 사용.
class _ProgressBadge extends StatelessWidget {
  final int progress;
  final String? legend;

  const _ProgressBadge({required this.progress, this.legend});

  static ({Color bg, Color fg}) _colors(String? legend) {
    switch (legend) {
      case 'success':
        return (bg: const Color(0xFFECFDF5), fg: const Color(0xFF059669));
      case 'primary':
        return (bg: const Color(0xFFEEF2FF), fg: AppTheme.primary);
      case 'warning':
        return (bg: const Color(0xFFFFFBEB), fg: const Color(0xFFD97706));
      default:
        return (bg: const Color(0xFFFEF2F2), fg: const Color(0xFFDC2626));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _colors(legend);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.fg.withOpacity(0.25), width: 1),
      ),
      child: Text(
        '$progress%',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: c.fg,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
