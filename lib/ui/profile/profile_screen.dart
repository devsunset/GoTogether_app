import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gotogether/data/di/service_locator.dart';
import 'package:gotogether/ui/app_theme.dart';
import 'package:gotogether/ui/profile/user_controller.dart';
import 'package:gotogether/ui/profile/profile_edit_screen.dart';
import 'package:gotogether/ui/widgets/screen_helpers.dart';

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
      backgroundColor: AppTheme.notWhite,
      body: Column(
        children: [
          const Expanded(flex: 2, child: _TopPortion()),
          Expanded(
            flex: 8,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                d['nickname']?.toString() ?? '-',
                                style: Theme.of(context).textTheme.headline6?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.darkerText,
                                ),
                              ),
                              FilledButton.tonal(
                                onPressed: _edit,
                                child: const Text('수정'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ..._profileRows(d),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _profileRows(Map<String, dynamic> d) {
    final list = <Widget>[];
    void add(String label, String? value) {
      if (value != null && value.isNotEmpty) {
        list.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.lightText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, color: AppTheme.darkText),
                ),
              ],
            ),
          ),
        );
      }
    }
    add('소개', d['introduce']?.toString());
    add('메모', d['note']?.toString());
    add('Github', d['github']?.toString());
    add('홈페이지', d['homepage']?.toString());
    add('스킬', d['skill']?.toString());
    return list;
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
