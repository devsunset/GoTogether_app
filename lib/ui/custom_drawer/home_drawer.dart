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
    return Scaffold(
      backgroundColor: AppTheme.notWhite.withOpacity(0.5),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 40.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  AnimatedBuilder(
                    animation: widget.iconAnimationController!,
                    builder: (BuildContext context, Widget? child) {
                      return ScaleTransition(
                        scale: AlwaysStoppedAnimation<double>(1.0 -
                            (widget.iconAnimationController!.value) * 0.2),
                        child: RotationTransition(
                          turns: AlwaysStoppedAnimation<double>(Tween<double>(
                                      begin: 0.0, end: 24.0)
                                  .animate(CurvedAnimation(
                                      parent: widget.iconAnimationController!,
                                      curve: Curves.fastOutSlowIn))
                                  .value /
                              360),
                          child: Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: AppTheme.grey.withOpacity(0.6),
                                    offset: const Offset(2.0, 4.0),
                                    blurRadius: 8),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(60.0)),
                              child: Image.asset('assets/images/userImage.png'),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  FutureBuilder(
                      future: getNickanme(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        //해당 부분은 data를 아직 받아 오지 못했을때 실행되는 부분을 의미한다.
                        if (snapshot.hasData == false) {
                          return CircularProgressIndicator();
                        }
                        //error가 발생하게 될 경우 반환하게 되는 부분
                        else if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8, left: 4),
                            child: Text(
                              'Anonymous',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isLightMode
                                    ? AppTheme.grey
                                    : AppTheme.white,
                                fontSize: 18,
                              ),
                            ),
                          );
                        }
                        // 데이터를 정상적으로 받아오게 되면 다음 부분을 실행하게 되는 것이다.
                        else {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8, left: 4),
                            child: Text(
                              snapshot.data.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isLightMode
                                    ? AppTheme.grey
                                    : AppTheme.white,
                                fontSize: 18,
                              ),
                            ),
                          );
                        }
                      }),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Divider(
            height: 1,
            color: AppTheme.grey.withOpacity(0.6),
          ),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(0.0),
              itemCount: drawerList?.length,
              itemBuilder: (BuildContext context, int index) {
                return inkwell(drawerList![index]);
              },
            ),
          ),
          Divider(
            height: 1,
            color: AppTheme.grey.withOpacity(0.6),
          ),
          Column(
            children: <Widget>[
              FutureBuilder(
                  future: getNickanme(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    //해당 부분은 data를 아직 받아 오지 못했을때 실행되는 부분을 의미한다.
                    if (snapshot.hasData == false) {
                      return CircularProgressIndicator();
                    }
                    //error가 발생하게 될 경우 반환하게 되는 부분
                    else if (snapshot.hasError) {
                      return ListTile(
                        title: Text(
                          'Sign In',
                          style: TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppTheme.darkText,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        trailing: Icon(
                          Icons.power_settings_new,
                          color: Colors.red,
                        ),
                        onTap: () {
                          onTapped('');
                        },
                      );
                    }
                    // 데이터를 정상적으로 받아오게 되면 다음 부분을 실행하게 되는 것이다.
                    else {
                      return ListTile(
                        title: Text(
                          snapshot.data.toString() == 'Anonymous'
                              ? 'Sign In'
                              : 'Log Out',
                          style: TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppTheme.darkText,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        trailing: Icon(
                          Icons.power_settings_new,
                          color: Colors.red,
                        ),
                        onTap: () {
                          onTapped(snapshot.data.toString());
                        },
                      );
                    }
                  }),
              SizedBox(
                height: MediaQuery.of(context).padding.bottom,
              )
            ],
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.grey.withOpacity(0.1),
        highlightColor: Colors.transparent,
        onTap: () {
          navigationtoScreen(listData.index!);
        },
        child: Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 6.0,
                    height: 46.0,
                    // decoration: BoxDecoration(
                    //   color: widget.screenIndex == listData.index
                    //       ? Colors.blue
                    //       : Colors.transparent,
                    //   borderRadius: new BorderRadius.only(
                    //     topLeft: Radius.circular(0),
                    //     topRight: Radius.circular(16),
                    //     bottomLeft: Radius.circular(0),
                    //     bottomRight: Radius.circular(16),
                    //   ),
                    // ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(4.0),
                  ),
                  listData.isAssetsImage
                      ? Container(
                          width: 24,
                          height: 24,
                          child: Image.asset(listData.imageName,
                              color: widget.screenIndex == listData.index
                                  ? Colors.blue
                                  : AppTheme.nearlyBlack),
                        )
                      : Icon(listData.icon?.icon,
                          color: widget.screenIndex == listData.index
                              ? Colors.blue
                              : AppTheme.nearlyBlack),
                  const Padding(
                    padding: EdgeInsets.all(4.0),
                  ),
                  Text(
                    listData.labelName,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: widget.screenIndex == listData.index
                          ? Colors.black
                          : AppTheme.nearlyBlack,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            widget.screenIndex == listData.index
                ? AnimatedBuilder(
                    animation: widget.iconAnimationController!,
                    builder: (BuildContext context, Widget? child) {
                      return Transform(
                        transform: Matrix4.translationValues(
                            (MediaQuery.of(context).size.width * 0.75 - 64) *
                                (1.0 -
                                    widget.iconAnimationController!.value -
                                    1.0),
                            0.0,
                            0.0),
                        child: Padding(
                          padding: EdgeInsets.only(top: 8, bottom: 8),
                          child: Container(
                            width:
                                MediaQuery.of(context).size.width * 0.75 - 64,
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: new BorderRadius.only(
                                topLeft: Radius.circular(0),
                                topRight: Radius.circular(28),
                                bottomLeft: Radius.circular(0),
                                bottomRight: Radius.circular(28),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : const SizedBox()
          ],
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
