import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gotogether/data/di/service_locator.dart';
import 'package:gotogether/data/repository/together/together_repository.dart';
import 'package:gotogether/ui/app_theme.dart';
import 'package:gotogether/ui/together/together_edit_screen.dart';
import 'package:gotogether/ui/widgets/html_content_view.dart';
import 'package:gotogether/ui/widgets/kakao_map_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class TogetherDetailScreen extends StatefulWidget {
  final int togetherId;

  const TogetherDetailScreen({Key? key, required this.togetherId}) : super(key: key);

  @override
  State<TogetherDetailScreen> createState() => _TogetherDetailScreenState();
}

class _TogetherDetailScreenState extends State<TogetherDetailScreen> {
  final TogetherRepository _repo = getIt<TogetherRepository>();
  static const _storage = FlutterSecureStorage();
  Map<String, dynamic>? _data;
  List<dynamic> _comments = [];
  bool _loading = true;
  String? _error;
  String? _currentUsername;
  String? _currentRole;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
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
      final res = await _repo.get(widget.togetherId);
      final comments = await _repo.getCommentList(widget.togetherId);
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

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      Fluttertoast.showToast(msg: 'Comment 내용을 입력해 주세요.');
      return;
    }
    try {
      await _repo.createComment({
        'togetherId': widget.togetherId,
        'content': text,
      });
      _commentController.clear();
      _load();
      Fluttertoast.showToast(msg: '저장되었습니다.');
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
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

  Future<void> _edit() async {
    final needRefresh = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TogetherEditScreen(togetherId: widget.togetherId, initialData: _data),
      ),
    );
    if (needRefresh == true) _load();
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete'),
        content: const Text('Delete this Together?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _repo.delete(widget.togetherId);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Together')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Together')),
        body: Center(child: Text(_error!)),
      );
    }
    final d = _data ?? {};
    final togetherId = widget.togetherId;
    return Scaffold(
      key: ValueKey('together_detail_scaffold_$togetherId'),
      backgroundColor: AppTheme.nearlyWhite,
      appBar: AppBar(
        title: const Text('Together'),
        backgroundColor: AppTheme.nearlyWhite,
        elevation: 0,
        actions: [
          if (_canEditDelete) ...[
            IconButton(icon: const Icon(Icons.edit), onPressed: _edit, tooltip: '수정'),
            IconButton(icon: const Icon(Icons.delete), onPressed: _delete, tooltip: '삭제'),
          ],
        ],
      ),
      body: RepaintBoundary(
        child: KeyedSubtree(
          key: ValueKey('together_detail_body_$togetherId'),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        d['title']?.toString() ?? '',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.visibility_outlined, size: 16, color: AppTheme.lightText),
                        const SizedBox(width: 4),
                        Text('${d['hit'] ?? 0}', style: const TextStyle(fontSize: 13, color: AppTheme.lightText)),
                        const SizedBox(width: 12),
                        Icon(Icons.chat_bubble_outline, size: 16, color: AppTheme.lightText),
                        const SizedBox(width: 4),
                        Text('${_comments.length}', style: const TextStyle(fontSize: 13, color: AppTheme.lightText)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('${d['nickname'] ?? ''} · ${d['modifiedDate'] ?? d['createdDate'] ?? ''}'),
                const Divider(),
                HtmlContentView(key: ValueKey('html_content_$togetherId'), content: d['content']?.toString()),
                if (d['maxMember'] != null || d['currentMember'] != null) ...[
                  const SizedBox(height: 12),
                  Text('최대 모집 인원: ${d['maxMember'] ?? '-'} · 현재 참여 인원: ${d['currentMember'] ?? '-'}', style: const TextStyle(fontSize: 13, color: AppTheme.lightText)),
                ],
                if (d['openKakaoChat']?.toString().trim().isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final url = d['openKakaoChat']?.toString().trim() ?? '';
                      if (url.isEmpty) return;
                      final uri = Uri.tryParse(url.startsWith('http') ? url : 'https://$url');
                      if (uri != null && await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                    },
                    child: Text('Kakao Open Chat: ${d['openKakaoChat']}', style: const TextStyle(fontSize: 14, color: Colors.blue, decoration: TextDecoration.underline)),
                  ),
                ],
                if (_skillEntries(d['skill']).isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Skill', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  _SkillLegend(),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: _skillEntries(d['skill']).map((e) => _SkillChip(item: e.item, level: e.level)).toList(),
                  ),
                ],
                const SizedBox(height: 16),
                const Text('참여 방식', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(_involveTypeLabel(d['involveType']?.toString())),
                if (_showMapOnDetail(d)) ...[
                  const SizedBox(height: 12),
                  const Text('모임 장소', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  KakaoMapWidget(
                    mode: 'view',
                    lat: _parseDouble(d['latitude']),
                    lng: _parseDouble(d['longitude']),
                    height: 280,
                  ),
                ],
                const SizedBox(height: 16),
                const Text('Comments', style: TextStyle(fontWeight: FontWeight.bold)),
                ...List.generate(_comments.length, (i) {
                  final c = _comments[i];
                  final map = c is Map ? c : {};
                  final rawId = map['togetherCommentId'] ?? map['id'];
                  final intId = rawId == null ? null : (rawId is int ? rawId : (rawId is num ? rawId.toInt() : int.tryParse(rawId.toString())));
                  return Card(
                    key: ValueKey('comment_${togetherId}_$i'),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(map['nickname']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(map['modifiedDate']?.toString() ?? map['createdDate']?.toString() ?? '', style: const TextStyle(fontSize: 12, color: AppTheme.lightText)),
                          const SizedBox(height: 6),
                          Text(map['content']?.toString() ?? '', style: const TextStyle(fontSize: 14), maxLines: 20, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                      trailing: _canDeleteComment(c) && intId != null && intId > 0
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () => _deleteComment(intId),
                              tooltip: '댓글 삭제',
                            )
                          : null,
                      isThreeLine: true,
                    ),
                  );
                }),
                const SizedBox(height: 16),
                if (_currentUsername != null && _currentUsername!.isNotEmpty) ...[
                  const Text('Reply', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _commentController,
                    maxLines: 5,
                    maxLength: 1000,
                    decoration: const InputDecoration(
                      hintText: 'Comment를 남겨 보세요.',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: _addComment,
                      child: const Text('Submit'),
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 24),
                        SizedBox(width: 12),
                        Expanded(child: Text('로그인을 하시면 댓글 작성이 가능합니다.', style: TextStyle(color: Colors.blue, fontSize: 14))),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _involveTypeLabel(String? v) {
    switch (v?.toUpperCase()) {
      case 'ONLINE': return 'ON LINE 참여';
      case 'OFFLINE': return 'OFF LINE 참여';
      case 'ONOFFLINE': return 'ON/OFF LINE 참여';
      default: return v ?? '';
    }
  }

  static bool _showMapOnDetail(Map<String, dynamic> d) {
    final type = d['involveType']?.toString().toUpperCase() ?? '';
    if (type == 'ONLINE') return false;
    final lat = _parseDouble(d['latitude']);
    final lng = _parseDouble(d['longitude']);
    return lat != null && lng != null;
  }

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim());
    return null;
  }

  /// Vue와 동일: "item1^LEVEL1|item2^LEVEL2" 파싱
  static List<_SkillEntry> _skillEntries(dynamic skill) {
    final raw = skill?.toString().trim() ?? '';
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
}

/// Vue 상세와 동일: 레벨별 범례 (기본 학습·업무 사용·관심 있음·Toy Pjt.)
class _SkillLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        _legendChip('기본 학습', const Color(0xFF059669), const Color(0xFFECFDF5)),
        _legendChip('업무 사용', const Color(0xFFDC2626), const Color(0xFFFEF2F2)),
        _legendChip('관심 있음', const Color(0xFFD97706), const Color(0xFFFFFBEB)),
        _legendChip('Toy Pjt.', AppTheme.primary, const Color(0xFFEEF2FF)),
      ],
    );
  }

  static Widget _legendChip(String label, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: fg.withOpacity(0.3))),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: fg)),
    );
  }
}

/// Vue 상세와 동일: BASIC=success, JOB=danger, TOY_PROJECT=primary, else=warning
class _SkillChip extends StatelessWidget {
  final String item;
  final String level;

  const _SkillChip({required this.item, required this.level});

  static _SkillColorPair _colors(String level) {
    switch (level.toUpperCase()) {
      case 'BASIC':
        return _SkillColorPair(const Color(0xFF059669), const Color(0xFFECFDF5));
      case 'JOB':
        return _SkillColorPair(const Color(0xFFDC2626), const Color(0xFFFEF2F2));
      case 'TOY_PROJECT':
        return _SkillColorPair(AppTheme.primary, const Color(0xFFEEF2FF));
      default:
        return _SkillColorPair(const Color(0xFFD97706), const Color(0xFFFFFBEB));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _colors(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.fg.withOpacity(0.25)),
      ),
      child: Text(item, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: c.fg)),
    );
  }
}

class _SkillEntry {
  final String item;
  final String level;
  _SkillEntry(this.item, this.level);
}

class _SkillColorPair {
  final Color fg;
  final Color bg;
  _SkillColorPair(this.fg, this.bg);
}
