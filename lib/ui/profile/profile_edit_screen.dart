import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gotogether/data/di/service_locator.dart';
import 'package:gotogether/data/repository/user/user_repository.dart';
import 'package:gotogether/ui/app_theme.dart';

/// Vue 프로필과 동일: 스킬 형식 "item^level|item^level|..." (레벨: BASIC, JOB, INTEREST, TOY_PROJECT)
class ProfileEditScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const ProfileEditScreen({Key? key, this.initialData}) : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final UserRepository _repo = getIt<UserRepository>();
  final _formKey = GlobalKey<FormState>();
  final _introduceController = TextEditingController();
  final _noteController = TextEditingController();
  final _githubController = TextEditingController();
  final _homepageController = TextEditingController();

  /// 스킬 목록: 각 항목은 { item: 스킬명, level: BASIC|JOB|INTEREST|TOY_PROJECT }
  List<SkillItem> _skillItems = [];
  bool _saving = false;

  static const List<String> _skillLevels = ['BASIC', 'JOB', 'INTEREST', 'TOY_PROJECT'];
  static const Map<String, String> _skillLevelLabels = {
    'BASIC': '기본 학습',
    'JOB': '업무 사용',
    'INTEREST': '관심 있음',
    'TOY_PROJECT': 'Toy Pjt.',
  };

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    if (d != null) {
      _introduceController.text = d['introduce']?.toString() ?? '';
      _noteController.text = d['note']?.toString() ?? '';
      _githubController.text = d['github']?.toString() ?? '';
      _homepageController.text = d['homepage']?.toString() ?? '';
      _parseSkill(d['skill']?.toString());
    }
    if (_skillItems.isEmpty) {
      _skillItems.add(SkillItem(item: '', level: 'INTEREST'));
    }
  }

  /// Vue와 동일: "item^level|item^level" 파싱
  void _parseSkill(String? skillStr) {
    if (skillStr == null || skillStr.trim().isEmpty) {
      _skillItems = [SkillItem(item: '', level: 'INTEREST')];
      return;
    }
    final parts = skillStr.split('|');
    _skillItems = parts.map((s) {
      final sub = s.split('^');
      final item = sub.isNotEmpty ? sub[0] : '';
      final level = sub.length > 1 && _skillLevels.contains(sub[1]) ? sub[1] : 'INTEREST';
      return SkillItem(item: item, level: level);
    }).toList();
    if (_skillItems.isEmpty) {
      _skillItems.add(SkillItem(item: '', level: 'INTEREST'));
    }
  }

  /// Vue와 동일: item에서 |, ^ 제거 후 "item^level|" 형식으로 결합
  String _buildSkillString() {
    final buf = <String>[];
    for (final d in _skillItems) {
      final tmp = d.item.trim().replaceAll('|', '').replaceAll('^', '');
      if (tmp.isNotEmpty) {
        buf.add('$tmp^${d.level}');
      }
    }
    return buf.join('|');
  }

  void _addSkill() {
    setState(() => _skillItems.add(SkillItem(item: '', level: 'INTEREST')));
  }

  void _removeSkill(int index) {
    if (_skillItems.length <= 1) return;
    setState(() => _skillItems.removeAt(index));
  }

  @override
  void dispose() {
    _introduceController.dispose();
    _noteController.dispose();
    _githubController.dispose();
    _homepageController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _repo.saveUserInfo({
        'introduce': _introduceController.text.trim(),
        'note': _noteController.text.trim(),
        'github': _githubController.text.trim(),
        'homepage': _homepageController.text.trim(),
        'skill': _buildSkillString(),
      });
      Fluttertoast.showToast(msg: '저장되었습니다.');
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
      appBar: AppBar(title: const Text('프로필 수정')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _introduceController,
              decoration: const InputDecoration(labelText: '한줄 소개 (Introduce)', hintText: '한줄 소개'),
              maxLength: 255,
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: '자기 소개 (Note)', hintText: '자기 소개'),
              maxLength: 1000,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _githubController,
              decoration: const InputDecoration(labelText: 'Github'),
              maxLength: 500,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _homepageController,
              decoration: const InputDecoration(labelText: 'Homepage'),
              maxLength: 500,
            ),
            const SizedBox(height: 24),
            const Text('Skill 항목을 추가해 주세요.', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 12),
            ...List.generate(_skillItems.length, (index) {
              final skill = _skillItems[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        initialValue: skill.item,
                        decoration: const InputDecoration(
                          hintText: 'skill을 입력해주세요',
                          isDense: true,
                        ),
                        maxLength: 100,
                        onChanged: (v) => skill.item = v,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: skill.level,
                        decoration: const InputDecoration(isDense: true),
                        items: _skillLevels.map((e) => DropdownMenuItem(value: e, child: Text(_skillLevelLabels[e] ?? e))).toList(),
                        onChanged: (v) => setState(() => skill.level = v ?? 'INTEREST'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 48,
                      child: Column(
                        children: [
                          if (index < _skillItems.length - 1)
                            IconButton(
                              onPressed: () => _removeSkill(index),
                              icon: const Icon(Icons.remove_circle_outline),
                              color: AppTheme.primary,
                              tooltip: '삭제',
                            )
                          else
                            IconButton(
                              onPressed: _addSkill,
                              icon: const Icon(Icons.add_circle_outline),
                              color: AppTheme.primary,
                              tooltip: '추가',
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}

class SkillItem {
  String item;
  String level;

  SkillItem({required this.item, required this.level});
}
