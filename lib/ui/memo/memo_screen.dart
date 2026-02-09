import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gotogether/data/di/service_locator.dart';
import 'package:gotogether/data/models/memo/memo_list_item.dart';
import 'package:gotogether/data/repository/memo/memo_repository.dart';
import 'package:gotogether/ui/app_theme.dart';
import 'package:gotogether/ui/widgets/screen_helpers.dart';

/// Vue와 동일: 수신/발신 탭, 체크박스+선택 삭제, 펼침+답장(Send), New 뱃지, 열 때 읽음 처리. Vue에는 별도 쓰기 버튼 없음.
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
  bool _detailDisplayAll = false;
  final Set<int> _receiveExpanded = {};
  final Set<int> _sendExpanded = {};
  final Set<int> _receiveSelected = {};
  final Set<int> _sendSelected = {};
  final Map<int, TextEditingController> _replyControllers = {};
  final Map<int, bool> _sendingReply = {};

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
    for (final c in _replyControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadReceive() async {
    if (_loadingReceive) return;
    setState(() {
      _loadingReceive = true;
      _error = null;
    });
    try {
      final page = await _repo.getReceiveList(_receivePage, 5);
      setState(() {
        _receiveList = page.content;
        _receiveTotalPages = page.totalPages;
        _loadingReceive = false;
        for (final item in page.content) {
          if (item.memoId != null) {
            _replyControllers[item.memoId!] ??= TextEditingController();
          }
        }
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
      final page = await _repo.getSendList(_sendPage, 5);
      setState(() {
        _sendList = page.content;
        _sendTotalPages = page.totalPages;
        _loadingSend = false;
        for (final item in page.content) {
          if (item.memoId != null) {
            _replyControllers[item.memoId!] ??= TextEditingController();
          }
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loadingSend = false;
      });
    }
  }

  void _toggleDetailAll() {
    setState(() {
      _detailDisplayAll = !_detailDisplayAll;
      if (_detailDisplayAll) {
        _receiveExpanded.addAll(_receiveList.map((e) => e.memoId!).whereType<int>());
        _sendExpanded.addAll(_sendList.map((e) => e.memoId!).whereType<int>());
        for (int i = 0; i < _receiveList.length; i++) {
          if (_receiveList[i].readflag != 'Y') _setReadReceive(i);
        }
      } else {
        _receiveExpanded.clear();
        _sendExpanded.clear();
      }
    });
  }

  void _toggleExpandReceive(int index) {
    final id = _receiveList[index].memoId;
    if (id == null) return;
    setState(() {
      if (_receiveExpanded.contains(id)) {
        _receiveExpanded.remove(id);
      } else {
        _receiveExpanded.add(id);
        _setReadReceive(index);
      }
    });
  }

  void _toggleExpandSend(int index) {
    final id = _sendList[index].memoId;
    if (id == null) return;
    setState(() => _sendExpanded.contains(id) ? _sendExpanded.remove(id) : _sendExpanded.add(id));
  }

  Future<void> _setReadReceive(int index) async {
    final item = _receiveList[index];
    if (item.memoId == null || item.readflag == 'Y') return;
    try {
      await _repo.updateRead(item.memoId!);
      if (mounted) setState(() => _receiveList = List.from(_receiveList)..[index] = MemoListItem(
        memoId: item.memoId,
        memo: item.memo,
        createdDate: item.createdDate,
        modifiedDate: item.modifiedDate,
        readflag: 'Y',
        senderUsername: item.senderUsername,
        senderNickname: item.senderNickname,
        receiverUsername: item.receiverUsername,
        receiverNickname: item.receiverNickname,
      ));
    } catch (_) {}
  }

  void _toggleSelectReceive(int index) {
    final id = _receiveList[index].memoId;
    if (id == null) return;
    setState(() => _receiveSelected.contains(id) ? _receiveSelected.remove(id) : _receiveSelected.add(id));
  }

  void _toggleSelectSend(int index) {
    final id = _sendList[index].memoId;
    if (id == null) return;
    setState(() => _sendSelected.contains(id) ? _sendSelected.remove(id) : _sendSelected.add(id));
  }

  void _checkAllReceive(bool value) {
    setState(() {
      if (value) {
        _receiveSelected.addAll(_receiveList.map((e) => e.memoId!).whereType<int>());
      } else {
        _receiveSelected.clear();
      }
    });
  }

  void _checkAllSend(bool value) {
    setState(() {
      if (value) {
        _sendSelected.addAll(_sendList.map((e) => e.memoId!).whereType<int>());
      } else {
        _sendSelected.clear();
      }
    });
  }

  Future<void> _deleteSelectedReceive() async {
    if (_receiveSelected.isEmpty) {
      Fluttertoast.showToast(msg: '삭제할 메모를 선택해 주세요.');
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('삭제'),
        content: const Text('삭제 하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('삭제')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _repo.deleteReceive(_receiveSelected.toList());
      Fluttertoast.showToast(msg: '삭제되었습니다.');
      setState(() => _receiveSelected.clear());
      _loadReceive();
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> _deleteSelectedSend() async {
    if (_sendSelected.isEmpty) {
      Fluttertoast.showToast(msg: '삭제할 메모를 선택해 주세요.');
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('삭제'),
        content: const Text('삭제 하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('삭제')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _repo.deleteSend(_sendSelected.toList());
      Fluttertoast.showToast(msg: '삭제되었습니다.');
      setState(() => _sendSelected.clear());
      _loadSend();
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> _sendReply(bool isReceive, int index) async {
    final list = isReceive ? _receiveList : _sendList;
    final item = list[index];
    final memoId = item.memoId;
    if (memoId == null) return;
    final controller = _replyControllers[memoId];
    final text = controller?.text.trim() ?? '';
    if (text.isEmpty) {
      Fluttertoast.showToast(msg: '메모 내용을 입력해 주세요.');
      return;
    }
    final receiver = isReceive ? (item.senderUsername ?? '') : (item.receiverUsername ?? '');
    setState(() => _sendingReply[memoId] = true);
    try {
      await _repo.send(text, receiver);
      controller?.clear();
      Fluttertoast.showToast(msg: '전송되었습니다.');
      _loadReceive();
      _loadSend();
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      if (mounted) setState(() => _sendingReply[memoId] = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.notWhite,
      appBar: AppBar(
        title: const Text('Memo', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 2,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '수신 메모함'),
            Tab(text: '발신 메모함'),
          ],
        ),
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
                _buildReceiveList(),
                _buildSendList(),
              ],
            ),
    );
  }

  Widget _buildReceiveList() {
    if (_loadingReceive) return const LoadingView();
    if (_receiveList.isEmpty) {
      return const Center(child: Text('수신 메모함 데이타가 없습니다.'));
    }
    final allChecked = _receiveList.isNotEmpty &&
        _receiveList.every((e) => e.memoId != null && _receiveSelected.contains(e.memoId));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Checkbox(
                value: allChecked,
                onChanged: (v) => _checkAllReceive(v ?? false),
              ),
              const Text('Detail Display', style: TextStyle(fontSize: 13)),
              Switch(value: _detailDisplayAll, onChanged: (_) => _toggleDetailAll()),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _deleteSelectedReceive,
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _receiveList.length + (_receiveTotalPages > 1 ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _receiveList.length) {
                return PaginationBar(
                  page: _receivePage,
                  totalPages: _receiveTotalPages,
                  onPrev: _receivePage > 0 ? () { _receivePage--; _loadReceive(); } : null,
                  onNext: _receivePage < _receiveTotalPages - 1 ? () { _receivePage++; _loadReceive(); } : null,
                );
              }
              return _MemoCard(
                item: _receiveList[index],
                isReceive: true,
                expanded: _receiveList[index].memoId != null && _receiveExpanded.contains(_receiveList[index].memoId),
                selected: _receiveList[index].memoId != null && _receiveSelected.contains(_receiveList[index].memoId),
                onTap: () => _toggleExpandReceive(index),
                onToggleSelect: () => _toggleSelectReceive(index),
                replyController: _receiveList[index].memoId != null ? _replyControllers[_receiveList[index].memoId]! : null,
                sendingReply: _receiveList[index].memoId != null && (_sendingReply[_receiveList[index].memoId] ?? false),
                onSendReply: () => _sendReply(true, index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSendList() {
    if (_loadingSend) return const LoadingView();
    if (_sendList.isEmpty) {
      return const Center(child: Text('발신 메모함 데이타가 없습니다.'));
    }
    final allChecked = _sendList.isNotEmpty &&
        _sendList.every((e) => e.memoId != null && _sendSelected.contains(e.memoId));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Checkbox(
                value: allChecked,
                onChanged: (v) => _checkAllSend(v ?? false),
              ),
              const Text('Detail Display', style: TextStyle(fontSize: 13)),
              Switch(value: _detailDisplayAll, onChanged: (_) => _toggleDetailAll()),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _deleteSelectedSend,
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _sendList.length + (_sendTotalPages > 1 ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _sendList.length) {
                return PaginationBar(
                  page: _sendPage,
                  totalPages: _sendTotalPages,
                  onPrev: _sendPage > 0 ? () { _sendPage--; _loadSend(); } : null,
                  onNext: _sendPage < _sendTotalPages - 1 ? () { _sendPage++; _loadSend(); } : null,
                );
              }
              return _MemoCard(
                item: _sendList[index],
                isReceive: false,
                expanded: _sendList[index].memoId != null && _sendExpanded.contains(_sendList[index].memoId),
                selected: _sendList[index].memoId != null && _sendSelected.contains(_sendList[index].memoId),
                onTap: () => _toggleExpandSend(index),
                onToggleSelect: () => _toggleSelectSend(index),
                replyController: _sendList[index].memoId != null ? _replyControllers[_sendList[index].memoId]! : null,
                sendingReply: _sendList[index].memoId != null && (_sendingReply[_sendList[index].memoId] ?? false),
                onSendReply: () => _sendReply(false, index),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MemoCard extends StatelessWidget {
  final MemoListItem item;
  final bool isReceive;
  final bool expanded;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onToggleSelect;
  final TextEditingController? replyController;
  final bool sendingReply;
  final VoidCallback onSendReply;

  const _MemoCard({
    required this.item,
    required this.isReceive,
    required this.expanded,
    required this.selected,
    required this.onTap,
    required this.onToggleSelect,
    required this.replyController,
    required this.sendingReply,
    required this.onSendReply,
  });

  @override
  Widget build(BuildContext context) {
    final name = isReceive
        ? (item.senderNickname ?? item.senderUsername ?? '')
        : (item.receiverNickname ?? item.receiverUsername ?? '');
    final dateStr = item.createdDate ?? '';
    final shortDate = dateStr.length >= 10 ? dateStr.substring(0, 10) : dateStr;
    final isNew = isReceive && item.readflag == 'N';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: selected,
                    onChanged: (_) => onToggleSelect(),
                  ),
                  if (isNew)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('New', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                  Text(shortDate, style: const TextStyle(fontSize: 12, color: AppTheme.lightText)),
                  Icon(expanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
              if (expanded) ...[
                const Divider(height: 20),
                SelectableText(
                  item.memo ?? '',
                  style: const TextStyle(fontSize: 14),
                ),
                if (isReceive && item.readflag == 'Y' && item.modifiedDate != null && item.modifiedDate!.length >= 16) ...[
                  const SizedBox(height: 8),
                  Text('수신일시 ${item.modifiedDate!.substring(0, 16)}', style: const TextStyle(fontSize: 12, color: AppTheme.lightText)),
                ],
                const SizedBox(height: 12),
                Text(isReceive ? '답장전송' : '다시전송', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                if (replyController != null)
                  TextField(
                    controller: replyController,
                    maxLines: 3,
                    maxLength: 1000,
                    decoration: const InputDecoration(
                      hintText: '메모를 남겨 보세요.',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: sendingReply
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : FilledButton(
                          onPressed: onSendReply,
                          child: const Text('Send'),
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
