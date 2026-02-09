import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gotogether/data/di/service_locator.dart';
import 'package:gotogether/data/repository/memo/memo_repository.dart';

class MemoComposeScreen extends StatefulWidget {
  const MemoComposeScreen({Key? key}) : super(key: key);

  @override
  State<MemoComposeScreen> createState() => _MemoComposeScreenState();
}

class _MemoComposeScreenState extends State<MemoComposeScreen> {
  final MemoRepository _repo = getIt<MemoRepository>();
  final _formKey = GlobalKey<FormState>();
  final _receiverController = TextEditingController();
  final _memoController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _receiverController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      await _repo.send(
        _memoController.text.trim(),
        _receiverController.text.trim(),
      );
      Fluttertoast.showToast(msg: 'Sent');
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
      appBar: AppBar(title: const Text('New Memo')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _receiverController,
              decoration: const InputDecoration(labelText: 'Receiver (username)'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _memoController,
              decoration: const InputDecoration(labelText: 'Message'),
              maxLines: 5,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _send,
              child: _saving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}
