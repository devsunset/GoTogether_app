import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gotogether/data/di/service_locator.dart';
import 'package:gotogether/data/models/user/user_info_item.dart';
import 'package:gotogether/data/repository/memo/memo_repository.dart';
import 'package:gotogether/data/repository/user/user_repository.dart';
import 'package:gotogether/ui/app_theme.dart';
import 'package:gotogether/ui/widgets/screen_helpers.dart';
import 'package:url_launcher/url_launcher.dart';

/// Vue와 동일: Skill 범례, 펼침 상세(Introduce/Note/Github/Homepage/Skills), 메모 전송(로그인 시 본인 제외)
class MemberScreen extends StatefulWidget {
  const MemberScreen({Key? key}) : super(key: key);

  @override
  State<MemberScreen> createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MemberScreen> {
  final UserRepository _repo = getIt<UserRepository>();
  final MemoRepository _memoRepo = getIt<MemoRepository>();
  final TextEditingController _keywordController = TextEditingController();
  List<UserInfoItem> _list = [];
  int _page = 0;
  int _totalPages = 0;
  bool _loading = false;
  String? _error;
  String? _currentUsername;
  bool _detailDisplayAll = false;
  final Map<String, bool> _expanded = {};
  final Map<String, TextEditingController> _memoControllers = {};
  final Map<String, bool> _sendingMemo = {};

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _load();
  }

  Future<void> _loadCurrentUser() async {
    final storage = const FlutterSecureStorage();
    final username = await storage.read(key: 'USER_NAME');
    if (mounted) setState(() => _currentUsername = username);
  }

  @override
  void dispose() {
    _keywordController.dispose();
    for (final c in _memoControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await _repo.getUserInfoList(
        _page,
        5,
        keyword: _keywordController.text.isEmpty ? null : _keywordController.text,
      );
      setState(() {
        _list = page.content;
        _totalPages = page.totalPages;
        _loading = false;
        for (final item in page.content) {
          final u = item.username ?? '';
          _expanded[u] = _detailDisplayAll;
          _memoControllers[u] ??= TextEditingController();
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _toggleExpand(int index) {
    final u = _list[index].username ?? '';
    setState(() => _expanded[u] = !(_expanded[u] ?? false));
  }

  void _toggleDetailAll() {
    setState(() {
      _detailDisplayAll = !_detailDisplayAll;
      for (final k in _expanded.keys) {
        _expanded[k] = _detailDisplayAll;
      }
    });
  }

  Future<void> _sendMemo(int index) async {
    final item = _list[index];
    final username = item.username ?? '';
    final controller = _memoControllers[username];
    final text = controller?.text.trim() ?? '';
    if (text.isEmpty) {
      Fluttertoast.showToast(msg: '메모 내용을 입력해 주세요.');
      return;
    }
    setState(() => _sendingMemo[username] = true);
    try {
      await _memoRepo.send(text, username);
      controller?.clear();
      Fluttertoast.showToast(msg: '전송되었습니다.');
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      if (mounted) setState(() => _sendingMemo[username] = false);
    }
  }

  static List<_SkillEntry> _parseSkill(String? skill) {
    final raw = skill?.trim() ?? '';
    if (raw.isEmpty) return [];
    final list = <_SkillEntry>[];
    for (final part in raw.split('|')) {
      final s = part.trim();
      if (s.isEmpty) continue;
      final idx = s.indexOf('^');
      if (idx < 0) {
        list.add(_SkillEntry(s, 'INTEREST'));
      } else {
        list.add(_SkillEntry(s.substring(0, idx).trim(), s.substring(idx + 1).trim().toUpperCase()));
      }
    }
    return list;
  }

  static Color _skillColor(String level) {
    switch (level) {
      case 'BASIC': return const Color(0xFF059669);
      case 'JOB': return const Color(0xFFDC2626);
      case 'TOY_PROJECT': return AppTheme.primary;
      default: return const Color(0xFFD97706);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.notWhite,
      appBar: AppBar(
        title: const Text('Member', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _skillLegendChip('기본 학습', const Color(0xFF059669)),
                    _skillLegendChip('업무 사용', const Color(0xFFDC2626)),
                    _skillLegendChip('관심 있음', const Color(0xFFD97706)),
                    _skillLegendChip('Toy Pjt.', AppTheme.primary),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Detail Display', style: Theme.of(context).textTheme.bodySmall),
                    Switch(
                      value: _detailDisplayAll,
                      onChanged: (_) => _toggleDetailAll(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ModernSearchBar(
            controller: _keywordController,
            hintText: 'Search',
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
                  ? const EmptyView(message: '검색된 멤버가 없습니다.', icon: Icons.people_outline)
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
                        final u = _list[index].username ?? '';
                        return _MemberCard(
                          item: _list[index],
                          currentUsername: _currentUsername,
                          expanded: _expanded[u] ?? false,
                          onTap: () => _toggleExpand(index),
                          memoController: _memoControllers[u]!,
                          sendingMemo: _sendingMemo[u] ?? false,
                          onSendMemo: () => _sendMemo(index),
                          parseSkill: _parseSkill,
                          skillColor: _skillColor,
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }

  Widget _skillLegendChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: color)),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final UserInfoItem item;
  final String? currentUsername;
  final bool expanded;
  final VoidCallback onTap;
  final TextEditingController memoController;
  final bool sendingMemo;
  final VoidCallback onSendMemo;
  final List<_SkillEntry> Function(String?) parseSkill;
  final Color Function(String) skillColor;

  const _MemberCard({
    required this.item,
    required this.currentUsername,
    required this.expanded,
    required this.onTap,
    required this.memoController,
    required this.sendingMemo,
    required this.onSendMemo,
    required this.parseSkill,
    required this.skillColor,
  });

  @override
  Widget build(BuildContext context) {
    final canSendMemo = currentUsername != null &&
        currentUsername!.isNotEmpty &&
        currentUsername != item.username;
    final skills = parseSkill(item.skill);

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
                  CircleAvatar(
                    backgroundColor: AppTheme.chipBackground,
                    child: Text(
                      (item.nickname ?? item.username ?? '?').substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: AppTheme.grey),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.nickname ?? item.username ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: AppTheme.darkerText,
                          ),
                        ),
                        if (item.modifiedDate != null && item.modifiedDate!.length >= 10)
                          Text(
                            item.modifiedDate!.substring(0, 10),
                            style: const TextStyle(fontSize: 12, color: AppTheme.lightText),
                          ),
                      ],
                    ),
                  ),
                  Icon(expanded ? Icons.expand_less : Icons.expand_more, color: AppTheme.lightText),
                ],
              ),
              if (expanded) ...[
                const Divider(height: 24),
                _row('Introduce', item.introduce ?? ''),
                _row('Note', item.note ?? ''),
                if (item.github != null && item.github!.isNotEmpty)
                  _rowLink('Github', item.github!),
                if (item.homepage != null && item.homepage!.isNotEmpty)
                  _rowLink('Homepage', item.homepage!),
                if (skills.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Skills', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: skills.map((e) {
                      final c = skillColor(e.level);
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: c.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: c.withOpacity(0.3)),
                        ),
                        child: Text(e.item, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: c)),
                      );
                    }).toList(),
                  ),
                ],
                if (canSendMemo) ...[
                  const SizedBox(height: 16),
                  const Text('메모 전송', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: memoController,
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
                    child: sendingMemo
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))
                        : FilledButton(
                            onPressed: onSendMemo,
                            child: const Text('Send'),
                          ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text('$label', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(
            child: SelectableText(
              value.isEmpty ? '-' : value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowLink(String label, String url) {
    final link = url.trim().isEmpty ? null : (url.trim().startsWith('http') ? url.trim() : 'https://${url.trim()}');
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text('$label', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(
            child: link != null
                ? InkWell(
                    onTap: () async {
                      final uri = Uri.tryParse(link);
                      if (uri != null && await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                    },
                    child: Text(url, style: const TextStyle(fontSize: 13, color: Colors.blue, decoration: TextDecoration.underline)),
                  )
                : SelectableText(url.isEmpty ? '-' : url, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _SkillEntry {
  final String item;
  final String level;
  _SkillEntry(this.item, this.level);
}
