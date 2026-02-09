import 'package:flutter/material.dart';
import 'package:gotogether/data/di/service_locator.dart';
import 'package:gotogether/data/models/memo/memo_list_item.dart';
import 'package:gotogether/data/repository/memo/memo_repository.dart';
import 'package:gotogether/ui/app_theme.dart';
import 'package:gotogether/ui/widgets/screen_helpers.dart';
import 'package:gotogether/ui/memo/memo_compose_screen.dart';

class MemoScreen extends StatefulWidget {
  const MemoScreen({Key? key}) : super(key: key);

  @override
  State<MemoScreen> createState() => _MemoScreenState();
}

class _MemoScreenState extends State<MemoScreen> with SingleTickerProviderStateMixin {
  final MemoRepository _repo = getIt<MemoRepository>();
  late TabController _tabController;
  List<MemoListItem> _receiveList = [];
  List<MemoListItem> _sendList = [];
  int _receivePage = 0;
  int _sendPage = 0;
  int _receiveTotalPages = 0;
  int _sendTotalPages = 0;
  bool _loadingReceive = false;
  bool _loadingSend = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReceive();
    _loadSend();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReceive() async {
    if (_loadingReceive) return;
    setState(() {
      _loadingReceive = true;
      _error = null;
    });
    try {
      final page = await _repo.getReceiveList(_receivePage, 10);
      setState(() {
        _receiveList = page.content;
        _receiveTotalPages = page.totalPages;
        _loadingReceive = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loadingReceive = false;
      });
    }
  }

  Future<void> _loadSend() async {
    if (_loadingSend) return;
    setState(() {
      _loadingSend = true;
      _error = null;
    });
    try {
      final page = await _repo.getSendList(_sendPage, 10);
      setState(() {
        _sendList = page.content;
        _sendTotalPages = page.totalPages;
        _loadingSend = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loadingSend = false;
      });
    }
  }

  void _goCompose() async {
    final needRefresh = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const MemoComposeScreen()),
    );
    if (needRefresh == true) {
      _loadReceive();
      _loadSend();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.notWhite,
      appBar: AppBar(
        title: const Text('쪽지', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 2,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '받은 쪽지'),
            Tab(text: '보낸 쪽지'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            onPressed: _goCompose,
            tooltip: '쪽지 쓰기',
          ),
        ],
      ),
      body: _error != null
          ? ErrorView(
              message: _error!,
              onRetry: () {
                _loadReceive();
                _loadSend();
              },
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(
                  list: _receiveList,
                  loading: _loadingReceive,
                  page: _receivePage,
                  totalPages: _receiveTotalPages,
                  onPageChange: (p) {
                    _receivePage = p;
                    _loadReceive();
                  },
                  subtitle: (item) => '보낸 사람: ${item.senderNickname ?? item.senderUsername ?? ''}',
                ),
                _buildList(
                  list: _sendList,
                  loading: _loadingSend,
                  page: _sendPage,
                  totalPages: _sendTotalPages,
                  onPageChange: (p) {
                    _sendPage = p;
                    _loadSend();
                  },
                  subtitle: (item) => '받는 사람: ${item.receiverNickname ?? item.receiverUsername ?? ''}',
                ),
              ],
            ),
    );
  }

  Widget _buildList({
    required List<MemoListItem> list,
    required bool loading,
    required int page,
    required int totalPages,
    required void Function(int) onPageChange,
    required String Function(MemoListItem) subtitle,
  }) {
    if (loading) return const LoadingView();
    if (list.isEmpty) return const EmptyView(message: '쪽지가 없습니다.', icon: Icons.mail_outline);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length + (totalPages > 1 ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == list.length) {
          return PaginationBar(
            page: page,
            totalPages: totalPages,
            onPrev: page > 0 ? () => onPageChange(page - 1) : null,
            onNext: page < totalPages - 1 ? () => onPageChange(page + 1) : null,
          );
        }
        final item = list[index];
        final memo = item.memo ?? '';
        final preview = memo.length > 50 ? '${memo.substring(0, 50)}...' : memo;
        final dateStr = item.createdDate ?? '';
        final shortDate = dateStr.length > 16 ? dateStr.substring(0, 16) : dateStr;
        return ModernListCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                preview,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: AppTheme.darkerText),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                '${subtitle(item)} · $shortDate',
                style: const TextStyle(fontSize: 12, color: AppTheme.lightText),
              ),
            ],
          ),
        );
      },
    );
  }
}
