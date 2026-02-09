import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gotogether/data/di/service_locator.dart';
import 'package:gotogether/data/repository/together/together_repository.dart';

class TogetherEditScreen extends StatefulWidget {
  final int? togetherId;
  final Map<String, dynamic>? initialData;

  const TogetherEditScreen({Key? key, this.togetherId, this.initialData}) : super(key: key);

  @override
  State<TogetherEditScreen> createState() => _TogetherEditScreenState();
}

class _TogetherEditScreenState extends State<TogetherEditScreen> {
  final TogetherRepository _repo = getIt<TogetherRepository>();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _categoryController = TextEditingController();
  final _involveTypeController = TextEditingController();
  final _openKakaoChatController = TextEditingController();
  final _skillController = TextEditingController();
  int _maxMember = 2;
  int _currentMember = 1;
  bool _saving = false;

  bool get isEdit => widget.togetherId != null;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    if (d != null) {
      _titleController.text = d['title']?.toString() ?? '';
      _contentController.text = d['content']?.toString() ?? '';
      _categoryController.text = d['category']?.toString() ?? 'HOBBY';
      _involveTypeController.text = d['involveType']?.toString() ?? 'JOIN';
      _openKakaoChatController.text = d['openKakaoChat']?.toString() ?? '';
      _skillController.text = d['skill']?.toString() ?? '';
      _maxMember = (d['maxMember'] as int?) ?? 2;
      _currentMember = (d['currentMember'] as int?) ?? 1;
    } else {
      _categoryController.text = 'HOBBY';
      _involveTypeController.text = 'JOIN';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _categoryController.dispose();
    _involveTypeController.dispose();
    _openKakaoChatController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      final data = {
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'category': _categoryController.text.trim(),
        'involveType': _involveTypeController.text.trim(),
        'openKakaoChat': _openKakaoChatController.text.trim(),
        'latitude': '',
        'longitude': '',
        'maxMember': _maxMember,
        'currentMember': _currentMember,
        'skill': _skillController.text.trim(),
      };
      if (isEdit) {
        await _repo.update(widget.togetherId!, data);
      } else {
        await _repo.create(data);
      }
      Fluttertoast.showToast(msg: 'Saved');
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Together' : 'New Together')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _categoryController.text.isEmpty ? 'HOBBY' : _categoryController.text,
              decoration: const InputDecoration(labelText: 'Category'),
              items: ['HOBBY', 'SPORTS', 'STUDY', 'TRAVEL', 'ETC'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => _categoryController.text = v ?? 'HOBBY',
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 5,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _involveTypeController,
              decoration: const InputDecoration(labelText: 'Involve Type (JOIN/CREATE)'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _openKakaoChatController,
              decoration: const InputDecoration(labelText: 'Kakao Open Chat'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _skillController,
              decoration: const InputDecoration(labelText: 'Skill'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Max Member: '),
                Expanded(
                  child: Slider(
                    value: _maxMember.toDouble(),
                    min: 2,
                    max: 100,
                    divisions: 98,
                    onChanged: (v) => setState(() => _maxMember = v.toInt()),
                  ),
                ),
                Text('$_maxMember'),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
