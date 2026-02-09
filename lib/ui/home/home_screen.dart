/// 홈 진입점. LayoutScreen(통계·공지·Recent Together) 표시. Vue Home과 동일.
import 'package:flutter/material.dart';
import 'package:gotogether/ui/custom_drawer/home_drawer.dart';

import 'home_theme.dart';
import 'layout_screen.dart';

class HomeScreen extends StatefulWidget {
  final void Function(DrawerIndex)? onNavigateToDrawerIndex;

  const HomeScreen({Key? key, this.onNavigateToDrawerIndex}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  AnimationController? animationController;

  Widget tabBody = Container(
    color: HomeTheme.background,
  );

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    tabBody = LayoutScreen(
      animationController: animationController,
      onNavigateToDrawerIndex: widget.onNavigateToDrawerIndex,
    );
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HomeTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder<bool>(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            } else {
              return Stack(
                children: <Widget>[
                  tabBody,
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 1));
    return true;
  }
}
