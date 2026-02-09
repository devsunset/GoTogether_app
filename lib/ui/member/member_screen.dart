import 'package:flutter/material.dart';
import 'package:gotogether/data/di/service_locator.dart';
import 'package:gotogether/data/models/user/user_info_item.dart';
import 'package:gotogether/data/repository/user/user_repository.dart';
import 'package:gotogether/ui/app_theme.dart';
import 'package:gotogether/ui/widgets/screen_helpers.dart';

class MemberScreen extends StatefulWidget {
  const MemberScreen({Key? key}) : super(key: key);

  @override
  State<MemberScreen> createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MemberScreen> {
  final UserRepository _repo = getIt<UserRepository>();
  final TextEditingController _keywordController = TextEditingController();
  List<UserInfoItem> _list = [];
  int _page = 0;
  int _totalPages = 0;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _keywordController.dispose();
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
        10,
        keyword: _keywordController.text.isEmpty ? null : _keywordController.text,
      );
      setState(() {
        _list = page.content;
        _totalPages = page.totalPages;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.notWhite,
      appBar: AppBar(
        title: const Text('멤버', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      body: Column(
        children: [
          ModernSearchBar(
            controller: _keywordController,
            hintText: '닉네임·아이디 검색',
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
                  ? const EmptyView(message: '멤버가 없습니다.', icon: Icons.people_outline)
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
                        final item = _list[index];
                        return ModernListCard(
                          child: Row(
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
                                    if (item.introduce != null && item.introduce!.isNotEmpty)
                                      Text(
                                        item.introduce!,
                                        style: const TextStyle(fontSize: 13, color: AppTheme.lightText),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: AppTheme.lightText),
                            ],
                          ),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}
