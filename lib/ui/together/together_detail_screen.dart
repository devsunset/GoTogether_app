import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gotogether/data/di/service_locator.dart';
import 'package:gotogether/data/repository/together/together_repository.dart';
import 'package:gotogether/ui/app_theme.dart';
import 'package:gotogether/ui/together/together_edit_screen.dart';

class TogetherDetailScreen extends StatefulWidget {
  final int togetherId;

  const TogetherDetailScreen({Key? key, required this.togetherId}) : super(key: key);

  @override
  State<TogetherDetailScreen> createState() => _TogetherDetailScreenState();
}

class _TogetherDetailScreenState extends State<TogetherDetailScreen> {
  final TogetherRepository _repo = getIt<TogetherRepository>();
  Map<String, dynamic>? _data;
  List<dynamic> _comments = [];
  bool _loading = true;
  String? _error;
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
      final res = await _repo.get(widget.togetherId);
      final comments = await _repo.getCommentList(widget.togetherId);
      setState(() {
        _data = res.data;
        _comments = comments;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    try {
      await _repo.createComment({
        'togetherId': widget.togetherId,
        'content': text,
      });
      _commentController.clear();
      _load();
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
    return Scaffold(
      backgroundColor: AppTheme.nearlyWhite,
      appBar: AppBar(
        title: const Text('Together'),
        backgroundColor: AppTheme.nearlyWhite,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _edit),
          IconButton(icon: const Icon(Icons.delete), onPressed: _delete),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              d['title']?.toString() ?? '',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 8),
            Text('${d['nickname'] ?? ''} · ${d['createdDate'] ?? ''}'),
            const Divider(),
            Text(d['content']?.toString() ?? ''),
            if (d['openKakaoChat']?.toString().isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Kakao: ${d['openKakaoChat']}'),
              ),
            const SizedBox(height: 16),
            const Text('Comments', style: TextStyle(fontWeight: FontWeight.bold)),
            ..._comments.map((c) {
              final map = c is Map ? c : {};
              return ListTile(
                title: Text(map['content']?.toString() ?? ''),
                subtitle: Text(map['nickname']?.toString() ?? ''),
              );
            }),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Write a comment',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send), onPressed: _addComment),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
