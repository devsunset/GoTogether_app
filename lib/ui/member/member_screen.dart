import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gotogether/data/di/service_locator.dart';
import 'package:gotogether/data/models/user/user_info_item.dart';
import 'package:gotogether/data/repository/user/user_repository.dart';
import 'package:gotogether/ui/member/member_theme.dart';

class MemberScreen extends StatefulWidget {
  @override
  _MemberScreenState createState() => _MemberScreenState();
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
    return Theme(
      data: MemberTheme.buildLightTheme(),
      child: Scaffold(
        body: Column(
          children: [
            getAppBarUI(),
            getSearchBarUI(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: _list.isEmpty
                    ? const Center(child: Text('No Data.'))
                    : ListView.builder(
                        itemCount: _list.length + (_totalPages > 1 ? 1 : 0),
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          if (index == _list.length) {
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_page > 0)
                                    TextButton(
                                        onPressed: () {
                                          _page--;
                                          _load();
                                        },
                                        child: const Text('Prev')),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text('${_page + 1} / $_totalPages'),
                                  ),
                                  if (_page < _totalPages - 1)
                                    TextButton(
                                        onPressed: () {
                                          _page++;
                                          _load();
                                        },
                                        child: const Text('Next')),
                                ],
                              ),
                            );
                          }
                          final item = _list[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(item.nickname ?? item.username ?? ''),
                              subtitle: Text(item.introduce ?? item.username ?? ''),
                              trailing: const Icon(Icons.chevron_right),
                            ),
                          );
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }

  Widget getSearchBarUI() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _keywordController,
              decoration: const InputDecoration(
                hintText: 'Search...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onSubmitted: (_) {
                _page = 0;
                _load();
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(FontAwesomeIcons.magnifyingGlass, size: 20, color: MemberTheme.buildLightTheme().primaryColor),
            onPressed: () {
              _page = 0;
              _load();
            },
          ),
        ],
      ),
    );
  }

  Widget getAppBarUI() {
    return Container(
      decoration: BoxDecoration(
        color: MemberTheme.buildLightTheme().backgroundColor,
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              offset: const Offset(0, 2),
              blurRadius: 8.0),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top, left: 8, right: 8),
        child: Row(
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              width: AppBar().preferredSize.height + 40,
              height: AppBar().preferredSize.height,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(32.0),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                  // child: Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: Icon(Icons.arrow_back),
                  // ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Member',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            Container(
              width: AppBar().preferredSize.height + 40,
              height: AppBar().preferredSize.height,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(32.0),
                      ),
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
