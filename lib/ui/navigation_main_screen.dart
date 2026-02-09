/// 메인 네비게이션. 드로어 메뉴에 따라 화면 전환 (Vue Main 레이아웃과 동일).
import 'package:flutter/material.dart';
import 'package:gotogether/ui/app_theme.dart';
import 'package:gotogether/ui/custom_drawer/drawer_user_controller.dart';
import 'package:gotogether/ui/custom_drawer/home_drawer.dart';
import 'package:gotogether/ui/home/home_screen.dart';
import 'package:gotogether/ui/member/member_screen.dart';
import 'package:gotogether/ui/memo/memo_screen.dart';
import 'package:gotogether/ui/post/post_screen.dart';
import 'package:gotogether/ui/profile/profile_screen.dart';
import 'package:gotogether/ui/together/together_screen.dart';

class NavigationHomeScreen extends StatefulWidget {
  @override
  _NavigationHomeScreenState createState() => _NavigationHomeScreenState();
}

class _NavigationHomeScreenState extends State<NavigationHomeScreen> {
  Widget? screenView;
  DrawerIndex? drawerIndex;

  @override
  void initState() {
    drawerIndex = DrawerIndex.HOME;
    screenView = HomeScreen(onNavigateToDrawerIndex: changeIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.white,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          backgroundColor: AppTheme.surface,
          body: DrawerUserController(
            screenIndex: drawerIndex,
            drawerWidth: MediaQuery.of(context).size.width * 0.75,
            onDrawerCall: (DrawerIndex drawerIndexdata) {
              changeIndex(drawerIndexdata);
              //callback from drawer for replace screen as user need with passing DrawerIndex(Enum index)
            },
            screenView: screenView,
          ),
        ),
      ),
    );
  }

  void changeIndex(DrawerIndex drawerIndexdata) {
    if (drawerIndex != drawerIndexdata) {
      drawerIndex = drawerIndexdata;
      switch (drawerIndex) {
        case DrawerIndex.HOME:
          setState(() {
            screenView = HomeScreen();
          });
          break;
        case DrawerIndex.TOGETHER:
          setState(() {
            screenView = TogetherScreen();
          });
          break;
        case DrawerIndex.MEMBER:
          setState(() {
            screenView = MemberScreen();
          });
          break;
        case DrawerIndex.POST_TALK:
          setState(() {
            screenView = PostScreen(category: 'TALK');
          });
          break;
        case DrawerIndex.POST_QA:
          setState(() {
            screenView = PostScreen(category: 'QA');
          });
          break;
        case DrawerIndex.MEMO:
          setState(() {
            screenView = MemoScreen();
          });
          break;
        case DrawerIndex.PROFILE:
          setState(() {
            screenView = ProfileScreen();
          });
          break;
        default:
          break;
      }
    }
  }
}
