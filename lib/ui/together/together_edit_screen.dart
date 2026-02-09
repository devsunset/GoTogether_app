import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gotogether/data/di/service_locator.dart';
import 'package:gotogether/data/repository/together/together_repository.dart';
import 'package:gotogether/ui/widgets/html_editor_field.dart';
import 'package:gotogether/ui/widgets/kakao_map_widget.dart';
import 'package:quill_html_editor/quill_html_editor.dart';

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
  final _contentEditorController = QuillEditorController();
  final _categoryController = TextEditingController();
  final _involveTypeController = TextEditingController();
  final _openKakaoChatController = TextEditingController();
  /// Vue와 동일: Skill = item^LEVEL|... 편집용 (Item 텍스트 컨트롤러 + Level)
  List<TextEditingController> _skillItemControllers = [];
  List<String> _skillLevelsList = ['INTEREST'];

  int _maxMember = 4;
  int _currentMember = 1;
  bool _saving = false;
  /// Vue와 동일: 참여 방식이 ONLINE이 아닐 때 지도에서 선택한 위·경도
  double? _latitude;
  double? _longitude;

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim());
    return null;
  }

  static const List<String> _skillLevelOptions = ['INTEREST', 'BASIC', 'TOY_PROJECT', 'JOB'];
  static const Map<String, String> _skillLevelLabels = {
    'INTEREST': '관심 있음',
    'BASIC': '기본 학습',
    'TOY_PROJECT': 'Toy Pjt.',
    'JOB': '업무 사용',
  };

  bool get isEdit => widget.togetherId != null;

  void _parseSkillToItems(String? skillRaw) {
    _skillItemControllers.forEach((c) => c.dispose());
    _skillItemControllers = [];
    _skillLevelsList = [];
    final raw = skillRaw?.trim() ?? '';
    if (raw.isEmpty) {
      _skillItemControllers.add(TextEditingController(text: ''));
      _skillLevelsList.add('INTEREST');
      return;
    }
    for (final part in raw.split('|')) {
      final s = part.trim();
      if (s.isEmpty) continue;
      final idx = s.indexOf('^');
      if (idx < 0) {
        _skillItemControllers.add(TextEditingController(text: s));
        _skillLevelsList.add('INTEREST');
      } else {
        _skillItemControllers.add(TextEditingController(text: s.substring(0, idx).trim()));
        _skillLevelsList.add(s.substring(idx + 1).trim().toUpperCase());
      }
    }
    if (_skillItemControllers.isEmpty) {
      _skillItemControllers.add(TextEditingController(text: ''));
      _skillLevelsList.add('INTEREST');
    }
  }

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    if (d != null) {
      _titleController.text = d['title']?.toString() ?? '';
      _categoryController.text = d['category']?.toString() ?? 'STUDY';
      _involveTypeController.text = d['involveType']?.toString() ?? 'ONOFFLINE';
      _openKakaoChatController.text = d['openKakaoChat']?.toString() ?? '';
      _maxMember = (d['maxMember'] as int?) ?? 4;
      _currentMember = (d['currentMember'] as int?) ?? 1;
      _latitude = _parseDouble(d['latitude']);
      _longitude = _parseDouble(d['longitude']);
      _parseSkillToItems(d['skill']?.toString());
    } else {
      _categoryController.text = 'STUDY';
      _involveTypeController.text = 'ONOFFLINE';
      _latitude = null;
      _longitude = null;
      _parseSkillToItems(null);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _involveTypeController.dispose();
    _openKakaoChatController.dispose();
    _contentEditorController.dispose();
    for (final c in _skillItemControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addSkillRow() {
    setState(() {
      _skillItemControllers.add(TextEditingController(text: ''));
      _skillLevelsList.add('INTEREST');
    });
  }

  void _removeSkillRow(int index) {
    if (_skillItemControllers.length <= 1) return;
    setState(() {
      _skillItemControllers[index].dispose();
      _skillItemControllers.removeAt(index);
      _skillLevelsList.removeAt(index);
    });
  }

  /// Vue와 동일: item trim, |^ 제거, item^level| 이어붙여 마지막 | 제거
  String _buildSkillString() {
    final buf = StringBuffer();
    for (var i = 0; i < _skillItemControllers.length; i++) {
      final t = _skillItemControllers[i].text.trim().replaceAll('|', '').replaceAll('^', '');
      if (t.isEmpty) continue;
      buf.write('$t^${_skillLevelsList[i]}|');
    }
    final s = buf.toString();
    return s.endsWith('|') ? s.substring(0, s.length - 1) : s;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final contentHtml = (await _contentEditorController.getText()).trim();
    if (contentHtml.isEmpty) {
      Fluttertoast.showToast(msg: '본문을 입력하세요.');
      return;
    }
    setState(() => _saving = true);
    try {
      final skillStr = _buildSkillString();
    if (skillStr.isEmpty) {
      Fluttertoast.showToast(msg: '필요한 Skill 항목을 입력해 주세요.');
      setState(() => _saving = false);
      return;
    }
    final involveType = _involveTypeController.text.trim().toUpperCase();
    if (involveType != 'ONLINE') {
      if (_latitude == null || _longitude == null) {
        Fluttertoast.showToast(msg: '모임 장소를 지도에서 클릭해 선택해 주세요.');
        setState(() => _saving = false);
        return;
      }
    }
    final data = {
        'title': _titleController.text.trim(),
        'content': contentHtml,
        'category': _categoryController.text.trim(),
        'involveType': involveType,
        'openKakaoChat': _openKakaoChatController.text.trim(),
        'latitude': involveType == 'ONLINE' ? '' : (_latitude?.toString() ?? ''),
        'longitude': involveType == 'ONLINE' ? '' : (_longitude?.toString() ?? ''),
        'maxMember': _maxMember,
        'currentMember': _currentMember,
        'skill': skillStr,
      };
      if (isEdit) {
        await _repo.update(widget.togetherId!, data);
      } else {
        await _repo.create(data);
      }
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
      appBar: AppBar(title: Text(isEdit ? 'Together 수정' : 'Together 작성')),
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
              value: _categoryController.text.isEmpty ? 'STUDY' : _categoryController.text,
              decoration: const InputDecoration(labelText: '목적'),
              items: const [
                DropdownMenuItem(value: 'STUDY', child: Text('함께 공부해요')),
                DropdownMenuItem(value: 'PORTFOLIO', child: Text('포트폴리오 구축')),
                DropdownMenuItem(value: 'HACKATHON', child: Text('해커톤 참가')),
                DropdownMenuItem(value: 'CONTEST', child: Text('공모전 참가')),
                DropdownMenuItem(value: 'TOY_PROJECT', child: Text('토이 프로젝트 구축')),
                DropdownMenuItem(value: 'PROJECT', child: Text('프로젝트 구축')),
                DropdownMenuItem(value: 'ETC', child: Text('기타')),
              ],
              onChanged: (v) => setState(() => _categoryController.text = v ?? 'STUDY'),
            ),
            const SizedBox(height: 12),
            const Text('본문 (HTML 에디터)', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            const SizedBox(height: 8),
            HtmlEditorField(
              key: ValueKey('together-edit-${widget.togetherId ?? "new"}'),
              controller: _contentEditorController,
              initialHtml: widget.initialData?['content']?.toString(),
              hint: '본문을 입력하세요. 서식·링크·이미지 등을 사용할 수 있습니다.',
              height: 320,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _involveTypeController.text.isEmpty ? 'ONOFFLINE' : _involveTypeController.text,
              decoration: const InputDecoration(labelText: '참여 방식'),
              items: const [
                DropdownMenuItem(value: 'ONOFFLINE', child: Text('ON/OFF LINE')),
                DropdownMenuItem(value: 'OFFLINE', child: Text('OFF LINE')),
                DropdownMenuItem(value: 'ONLINE', child: Text('ON LINE')),
              ],
              onChanged: (v) => setState(() => _involveTypeController.text = v ?? 'ONOFFLINE'),
            ),
            if (_involveTypeController.text.toUpperCase() != 'ONLINE') ...[
              const SizedBox(height: 12),
              const Text('모임장소를 클릭하여 선택해 보세요.', style: TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 8),
              KakaoMapWidget(
                mode: 'edit',
                lat: _latitude,
                lng: _longitude,
                height: 300,
                onLocationSelected: (lat, lng) => setState(() {
                  _latitude = lat;
                  _longitude = lng;
                }),
              ),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: _openKakaoChatController,
              decoration: const InputDecoration(labelText: 'Kakao Open Chat (옵션)'),
            ),
            const SizedBox(height: 16),
            const Text('Skill', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            const Text('필요한 Skill 항목을 추가해 보세요.', style: TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 8),
            ...List.generate(_skillItemControllers.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _skillItemControllers[i],
                        decoration: const InputDecoration(
                          labelText: 'Item',
                          hintText: 'skill을 입력해주세요',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        maxLength: 100,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _skillLevelsList[i],
                        decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                        items: _skillLevelOptions.map((l) => DropdownMenuItem(value: l, child: Text(_skillLevelLabels[l] ?? l))).toList(),
                        onChanged: (v) => setState(() => _skillLevelsList[i] = v ?? 'INTEREST'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 48,
                      child: i == _skillItemControllers.length - 1
                          ? IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: _addSkillRow,
                              tooltip: '추가',
                            )
                          : IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => _removeSkillRow(i),
                              tooltip: '삭제',
                            ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            const Text('최대 모집 인원 / 현재 참여 인원', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _maxMember.clamp(1, 9),
                    decoration: const InputDecoration(labelText: '최대 모집 인원', isDense: true, border: OutlineInputBorder()),
                    items: List.generate(9, (i) => i + 1).map((v) => DropdownMenuItem(value: v, child: Text('$v'))).toList(),
                    onChanged: (v) => setState(() => _maxMember = v ?? 4),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _currentMember.clamp(0, 9),
                    decoration: const InputDecoration(labelText: '현재 참여 인원', isDense: true, border: OutlineInputBorder()),
                    items: List.generate(10, (i) => i).map((v) => DropdownMenuItem(value: v, child: Text('$v'))).toList(),
                    onChanged: (v) => setState(() => _currentMember = v ?? 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}
