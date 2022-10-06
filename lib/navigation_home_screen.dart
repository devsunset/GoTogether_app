import 'package:gotogether/app_theme.dart';
import 'package:gotogether/custom_drawer/drawer_user_controller.dart';
import 'package:gotogether/custom_drawer/home_drawer.dart';
import 'package:gotogether/feedback_screen.dart';
import 'package:gotogether/help_screen.dart';
import 'package:gotogether/home_screen.dart';
import 'package:gotogether/invite_friend_screen.dart';
import 'package:flutter/material.dart';

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
    screenView = const MyHomePage();
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
          backgroundColor: AppTheme.nearlyWhite,
          body: DrawerUserController(
            screenIndex: drawerIndex,
            drawerWidth: MediaQuery.of(context).size.width * 0.75,
            onDrawerCall: (DrawerIndex drawerIndexdata) {
              changeIndex(drawerIndexdata);
              //callback from drawer for replace screen as user need with passing DrawerIndex(Enum index)
            },
            screenView: screenView,
            //we replace screen view as we need on navigate starting screens like MyHomePage, HelpScreen, FeedbackScreen, etc...
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
            screenView = const MyHomePage();
          });
          break;
        case DrawerIndex.TOGETHER:
          setState(() {
            screenView = HelpScreen();
          });
          break;
        case DrawerIndex.MEMBER:
          setState(() {
            screenView = FeedbackScreen();
          });
          break;
        case DrawerIndex.POST:
          setState(() {
            screenView = FeedbackScreen();
          });
          break;
        case DrawerIndex.MEMO:
          setState(() {
            screenView = FeedbackScreen();
          });
          break;
        case DrawerIndex.PROFILE:
          setState(() {
            screenView = InviteFriend();
          });
          break;
        default:
          break;
      }
    }
  }
}
