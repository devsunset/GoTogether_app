import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gotogether/ui/app_theme.dart';
import 'package:gotogether/ui/sign/sign.dart';

import '../navigation_main_screen.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer(
      {Key? key,
      this.screenIndex,
      this.iconAnimationController,
      this.callBackIndex})
      : super(key: key);

  final AnimationController? iconAnimationController;
  final DrawerIndex? screenIndex;
  final Function(DrawerIndex)? callBackIndex;

  @override
  _HomeDrawerState createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  List<DrawerList>? drawerList;
  @override
  void initState() {
    setDrawerListArray();
    super.initState();
  }

  void setDrawerListArray() {
    Future<String> future = getNickanme();
    future.then((val) {
      if (val == 'Anonymous') {
        drawerList = <DrawerList>[
          DrawerList(
            index: DrawerIndex.HOME,
            labelName: 'Home',
            icon: Icon(Icons.home),
          ),
          DrawerList(
            index: DrawerIndex.TOGETHER,
            labelName: 'Together',
            icon: Icon(Icons.add_circle),
          ),
          DrawerList(
            index: DrawerIndex.MEMBER,
            labelName: 'Member',
            icon: Icon(Icons.group),
          ),
          DrawerList(
            index: DrawerIndex.POST,
            labelName: 'Post',
            icon: Icon(Icons.post_add),
          ),
        ];
      } else {
        drawerList = <DrawerList>[
          DrawerList(
            index: DrawerIndex.HOME,
            labelName: 'Home',
            icon: Icon(Icons.home),
          ),
          DrawerList(
            index: DrawerIndex.TOGETHER,
            labelName: 'Together',
            icon: Icon(Icons.add_circle),
          ),
          DrawerList(
            index: DrawerIndex.MEMBER,
            labelName: 'Member',
            icon: Icon(Icons.group),
          ),
          DrawerList(
            index: DrawerIndex.POST,
            labelName: 'Post',
            icon: Icon(Icons.post_add),
          ),
          DrawerList(
            index: DrawerIndex.MEMO,
            labelName: 'Memo',
            icon: Icon(Icons.edit),
          ),
          DrawerList(
            index: DrawerIndex.PROFILE,
            labelName: 'Profile',
            icon: Icon(Icons.account_box),
            // image example
            // isAssetsImage: true,
            // imageName: 'assets/images/supportIcon.png',
          ),
        ];
      }
    }).catchError((error) {
      drawerList = <DrawerList>[
        DrawerList(
          index: DrawerIndex.HOME,
          labelName: 'Home',
          icon: Icon(Icons.home),
        ),
        DrawerList(
          index: DrawerIndex.TOGETHER,
          labelName: 'Together',
          icon: Icon(Icons.add_circle),
        ),
        DrawerList(
          index: DrawerIndex.MEMBER,
          labelName: 'Member',
          icon: Icon(Icons.group),
        ),
        DrawerList(
          index: DrawerIndex.POST,
          labelName: 'Post',
          icon: Icon(Icons.post_add),
        ),
      ];
    });

    drawerList = <DrawerList>[
      DrawerList(
        index: DrawerIndex.HOME,
        labelName: 'Home',
        icon: Icon(Icons.home),
      ),
      DrawerList(
        index: DrawerIndex.TOGETHER,
        labelName: 'Together',
        icon: Icon(Icons.add_circle),
      ),
      DrawerList(
        index: DrawerIndex.MEMBER,
        labelName: 'Member',
        icon: Icon(Icons.group),
      ),
      DrawerList(
        index: DrawerIndex.POST,
        labelName: 'Post',
        icon: Icon(Icons.post_add),
      ),
    ];
  }

  Future<String> getNickanme() async {
    final storage = new FlutterSecureStorage();
    String? nickname = await storage.read(key: 'NICK_NAME');

    if (nickname == null || nickname == '') {
      nickname = 'Anonymous';
    }
    return nickname;
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AnimatedBuilder(
                  animation: widget.iconAnimationController!,
                  builder: (BuildContext context, Widget? child) {
                    return ScaleTransition(
                      scale: AlwaysStoppedAnimation<double>(1.0 -
                          (widget.iconAnimationController!.value) * 0.1),
                      child: Container(
                        height: 72,
                        width: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(36),
                          child: Image.asset(
                            'assets/images/userImage.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                FutureBuilder<String>(
                  future: getNickanme(),
                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (!snapshot.hasData && !snapshot.hasError) {
                      return SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary),
                      );
                    }
                    final name = snapshot.data ?? 'Anonymous';
                    return Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isLightMode ? AppTheme.darkerText : AppTheme.white,
                        fontSize: 18,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.border),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: drawerList?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                return inkwell(drawerList![index]);
              },
            ),
          ),
          Divider(height: 1, color: AppTheme.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: FutureBuilder<String>(
              future: getNickanme(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(height: 48);
                }
                final isAnonymous = snapshot.data == 'Anonymous';
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onTapped(snapshot.data ?? ''),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isAnonymous
                            ? theme.colorScheme.primary.withOpacity(0.12)
                            : AppTheme.chipBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isAnonymous ? Icons.login_rounded : Icons.logout_rounded,
                            size: 22,
                            color: isAnonymous ? theme.colorScheme.primary : AppTheme.darkText,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isAnonymous ? 'Sign In' : 'Log Out',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: isAnonymous ? theme.colorScheme.primary : AppTheme.darkText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void onTapped(String nickname) async {
    if (nickname == 'Anonymous') {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => SignIn()));
    } else {
      final storage = new FlutterSecureStorage();
      await storage.deleteAll();
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => NavigationHomeScreen()));
    }
  }

  Widget inkwell(DrawerList listData) {
    final theme = Theme.of(context);
    final isSelected = widget.screenIndex == listData.index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => navigationtoScreen(listData.index!),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primary.withOpacity(0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  listData.icon?.icon ?? Icons.circle,
                  size: 24,
                  color: isSelected ? theme.colorScheme.primary : AppTheme.dark_grey,
                ),
                const SizedBox(width: 16),
                Text(
                  listData.labelName,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 15,
                    color: isSelected ? theme.colorScheme.primary : AppTheme.darkerText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> navigationtoScreen(DrawerIndex indexScreen) async {
    widget.callBackIndex!(indexScreen);
  }
}

enum DrawerIndex {
  HOME,
  TOGETHER,
  MEMBER,
  POST,
  MEMO,
  PROFILE,
}

class DrawerList {
  DrawerList({
    this.isAssetsImage = false,
    this.labelName = '',
    this.icon,
    this.index,
    this.imageName = '',
  });

  String labelName;
  Icon? icon;
  bool isAssetsImage;
  String imageName;
  DrawerIndex? index;
}
