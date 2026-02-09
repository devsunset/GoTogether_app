import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gotogether/data/di/service_locator.dart';
import 'package:gotogether/data/repository/user/user_repository.dart';

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
  final _skillController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    if (d != null) {
      _introduceController.text = d['introduce']?.toString() ?? '';
      _noteController.text = d['note']?.toString() ?? '';
      _githubController.text = d['github']?.toString() ?? '';
      _homepageController.text = d['homepage']?.toString() ?? '';
      _skillController.text = d['skill']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _introduceController.dispose();
    _noteController.dispose();
    _githubController.dispose();
    _homepageController.dispose();
    _skillController.dispose();
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
        'skill': _skillController.text.trim(),
      });
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
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _introduceController,
              decoration: const InputDecoration(labelText: 'Introduce'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _githubController,
              decoration: const InputDecoration(labelText: 'Github'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _homepageController,
              decoration: const InputDecoration(labelText: 'Homepage'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _skillController,
              decoration: const InputDecoration(labelText: 'Skill'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
