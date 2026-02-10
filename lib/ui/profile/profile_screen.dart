import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gotogether/data/di/service_locator.dart';
import 'package:gotogether/ui/app_theme.dart';
import 'package:gotogether/ui/profile/user_controller.dart';
import 'package:gotogether/ui/profile/profile_edit_screen.dart';
import 'package:gotogether/ui/widgets/screen_helpers.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserController _userController = getIt<UserController>();
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _userController.getUserInfo();
      setState(() {
        _data = res.data is Map ? res.data as Map<String, dynamic> : null;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _edit() async {
    final needRefresh = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => ProfileEditScreen(initialData: _data)),
    );
    if (needRefresh == true) _load();
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM_RIGHT,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Column(
          children: [
            const Expanded(flex: 2, child: _TopPortion()),
            const Expanded(flex: 8, child: LoadingView()),
          ],
        ),
      );
    }
    if (_error != null) {
      return Scaffold(
        body: Column(
          children: [
            const Expanded(flex: 2, child: _TopPortion()),
            Expanded(flex: 8, child: ErrorView(message: _error!, onRetry: _load)),
          ],
        ),
      );
    }
    final d = _data ?? {};
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Column(
        children: [
          const Expanded(flex: 2, child: _TopPortion()),
          Expanded(
            flex: 8,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.paddingScreen),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DetailSection(
                      title: '프로필',
                      icon: Icons.person_outline,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            d['nickname']?.toString() ?? '-',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.darkerText,
                            ),
                          ),
                          FilledButton.tonal(
                            onPressed: _edit,
                            child: const Text('수정'),
                          ),
                        ],
                      ),
                    ),
                    if (_hasValue(d['introduce'])) ...[
                      const SizedBox(height: 12),
                      DetailSection(
                        title: '소개',
                        icon: Icons.info_outlined,
                        child: SelectableText(
                          d['introduce']?.toString() ?? '',
                          style: const TextStyle(fontSize: 14, color: AppTheme.darkText, height: 1.4),
                        ),
                      ),
                    ],
                    if (_hasValue(d['note'])) ...[
                      const SizedBox(height: 12),
                      DetailSection(
                        title: '메모',
                        icon: Icons.note_outlined,
                        child: SelectableText(
                          d['note']?.toString() ?? '',
                          style: const TextStyle(fontSize: 14, color: AppTheme.darkText, height: 1.4),
                        ),
                      ),
                    ],
                    if (_hasValue(d['github'])) ...[
                      const SizedBox(height: 12),
                      DetailSection(
                        title: 'Github',
                        icon: Icons.code,
                        child: _buildLink(d['github']!.toString()),
                      ),
                    ],
                    if (_hasValue(d['homepage'])) ...[
                      const SizedBox(height: 12),
                      DetailSection(
                        title: '홈페이지',
                        icon: Icons.language,
                        child: _buildLink(d['homepage']!.toString()),
                      ),
                    ],
                    if (_hasSkill(d['skill'])) ...[
                      const SizedBox(height: 12),
                      DetailSection(
                        title: '스킬',
                        icon: Icons.star_outline,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: _skillChips(d['skill']?.toString()),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static bool _hasValue(dynamic v) =>
      v != null && v.toString().trim().isNotEmpty;

  static bool _hasSkill(dynamic v) {
    final s = v?.toString().trim() ?? '';
    if (s.isEmpty) return false;
    for (final part in s.split('|')) {
      final item = part.split('^').first.trim();
      if (item.isNotEmpty) return true;
    }
    return false;
  }

  List<Widget> _skillChips(String? skillStr) {
    if (skillStr == null || skillStr.trim().isEmpty) return [];
    final chips = <Widget>[];
    for (final s in skillStr.split('|')) {
      final sub = s.split('^');
      if (sub.isEmpty) continue;
      final item = sub[0].trim();
      if (item.isEmpty) continue;
      final level = sub.length > 1 ? sub[1] : 'INTEREST';
      final color = _skillLevelColor(level);
      chips.add(
        Chip(
          label: Text(item, style: const TextStyle(fontSize: 12)),
          backgroundColor: color.withOpacity(0.2),
          side: BorderSide(color: color.withOpacity(0.5)),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    }
    return chips;
  }

  Widget _buildLink(String url) {
    final link = url.trim().isEmpty ? null : (url.trim().startsWith('http') ? url.trim() : 'https://${url.trim()}');
    if (link == null) return SelectableText(url, style: const TextStyle(fontSize: 14));
    return InkWell(
      onTap: () async {
        final uri = Uri.tryParse(link);
        if (uri != null && await canLaunchUrl(uri)) {
          launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Text(
        url,
        style: const TextStyle(fontSize: 14, color: AppTheme.primary, decoration: TextDecoration.underline),
      ),
    );
  }

  static Color _skillLevelColor(String level) {
    switch (level) {
      case 'BASIC': return Colors.green;
      case 'JOB': return Colors.red;
      case 'TOY_PROJECT': return AppTheme.primary;
      case 'INTEREST':
      default: return Colors.grey;
    }
  }
}

class _TopPortion extends StatelessWidget {
  const _TopPortion({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 50),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Color(0xff0043ba), Color(0xff006df1)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/images/userImage.png'),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
