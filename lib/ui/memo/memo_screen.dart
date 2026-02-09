import 'package:flutter/material.dart';
import 'package:gotogether/data/di/service_locator.dart';
import 'package:gotogether/data/models/memo/memo_list_item.dart';
import 'package:gotogether/data/repository/memo/memo_repository.dart';
import 'package:gotogether/ui/app_theme.dart';
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
      backgroundColor: AppTheme.nearlyWhite,
      appBar: AppBar(
        title: const Text('Memo'),
        backgroundColor: AppTheme.nearlyWhite,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Received'), Tab(text: 'Sent')],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _goCompose),
        ],
      ),
      body: _error != null
          ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
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
                  subtitle: (item) => 'From: ${item.senderNickname ?? item.senderUsername ?? ''}',
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
                  subtitle: (item) => 'To: ${item.receiverNickname ?? item.receiverUsername ?? ''}',
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
    if (loading) return const Center(child: CircularProgressIndicator());
    if (list.isEmpty) return const Center(child: Text('No Data.'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length + (totalPages > 1 ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == list.length) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (page > 0)
                  TextButton(onPressed: () => onPageChange(page - 1), child: const Text('Prev')),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('${page + 1} / $totalPages')),
                if (page < totalPages - 1)
                  TextButton(onPressed: () => onPageChange(page + 1), child: const Text('Next')),
              ],
            ),
          );
        }
        final item = list[index];
        final dateStr = item.createdDate ?? '';
        final shortDate = dateStr.length > 16 ? dateStr.substring(0, 16) : dateStr;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text((item.memo ?? '').length > 50 ? '${(item.memo ?? '').substring(0, 50)}...' : (item.memo ?? '')),
            subtitle: Text('${subtitle(item)} · $shortDate'),
            onTap: () {},
          ),
        );
      },
    );
  }
}
