/// 홈 레이아웃: 통계 4칸(Together/Member/Talk/Q&A)·공지·Recent Together Top 3.
/// 통계 탭 → 해당 메뉴, Recent 행 탭 → Together 상세.
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gotogether/data/di/service_locator.dart';
import 'package:gotogether/data/models/home/statistics_data.dart';
import 'package:gotogether/ui/custom_drawer/home_drawer.dart';
import 'package:gotogether/ui/app_theme.dart';
import 'package:gotogether/ui/home/home_theme.dart';
import 'package:gotogether/ui/home/notice_view.dart';
import 'package:gotogether/ui/home/recent_together_view.dart';
import 'package:gotogether/ui/home/statistics_view.dart';
import 'package:gotogether/ui/home/title_view.dart';
import 'package:gotogether/ui/memo/memo_screen.dart';
import 'package:gotogether/ui/together/together_detail_screen.dart';

import '../../data/models/data_model.dart';
import '../../data/models/home/recent_together_data.dart';
import 'home_controller.dart';

class LayoutScreen extends StatefulWidget {
  const LayoutScreen({Key? key, this.animationController, this.onNavigateToDrawerIndex}) : super(key: key);

  final AnimationController? animationController;
  final void Function(DrawerIndex)? onNavigateToDrawerIndex;
  @override
  _LayoutScreenState createState() => _LayoutScreenState();
}

class _LayoutScreenState extends State<LayoutScreen>
    with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;

  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  @override
  void initState() {
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));

    scrollController.addListener(() {
      if (scrollController.offset >= 24) {
        if (topBarOpacity != 1.0) {
          setState(() {
            topBarOpacity = 1.0;
          });
        }
      } else if (scrollController.offset <= 24 &&
          scrollController.offset >= 0) {
        if (topBarOpacity != scrollController.offset / 24) {
          setState(() {
            topBarOpacity = scrollController.offset / 24;
          });
        }
      } else if (scrollController.offset <= 0) {
        if (topBarOpacity != 0.0) {
          setState(() {
            topBarOpacity = 0.0;
          });
        }
      }
    });
    super.initState();
  }

  Future<bool> getData() async {
    const int count = 9;

    if (listViews.length > 0) {
      return true;
    }

    final homeController = getIt<HomeController>();

    try {
      DataModel dataModel = await homeController.getHome();
      final d = dataModel.data ?? {};
      int _parseCount(dynamic v) {
        if (v == null) return 0;
        if (v is int) return v;
        return int.tryParse(v.toString().replaceAll(',', '')) ?? 0;
      }

      List<StatisticsData> statisticsData = StatisticsData.getData(
          _parseCount(d['TOGETHER']),
          _parseCount(d['USER']),
          _parseCount(d['TALK']),
          _parseCount(d['QA']));

      listViews.add(
        TitleView(
          titleTxt: 'Statistics',
          subTxt: '',
          animation: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                  parent: widget.animationController!,
                  curve: Interval((1 / count) * 2, 1.0,
                      curve: Curves.fastOutSlowIn))),
          animationController: widget.animationController!,
        ),
      );

      listViews.add(
        StatisticsView(
          statisticsData: statisticsData,
          onNavigateToDrawerIndex: widget.onNavigateToDrawerIndex,
          mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                  parent: widget.animationController!,
                  curve: Interval((1 / count) * 3, 1.0,
                      curve: Curves.fastOutSlowIn))),
          mainScreenAnimationController: widget.animationController,
        ),
      );

      listViews.add(
        NoticeView(
            noticeText: d['NOTICE']?.toString() ?? '',
            animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                    parent: widget.animationController!,
                    curve: Interval((1 / count) * 8, 1.0,
                        curve: Curves.fastOutSlowIn))),
            animationController: widget.animationController!),
      );

      listViews.add(
        TitleView(
          titleTxt: 'Recent Together Top 3',
          subTxt: '',
          animation: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                  parent: widget.animationController!,
                  curve: Interval((1 / count) * 4, 1.0,
                      curve: Curves.fastOutSlowIn))),
          animationController: widget.animationController!,
        ),
      );

      final rawRecent = d['RECENT_TOGETHER'];
      final recentTogetherDataList = rawRecent is List
          ? rawRecent.map((e) => RecentTogetherData.fromJson(e as Map<String, dynamic>)).toList()
          : <RecentTogetherData>[];

      if (recentTogetherDataList.isNotEmpty) {
        for (int i = 0; i < recentTogetherDataList.length; i++) {
          final data = recentTogetherDataList[i];
          final togetherId = data.togetherId;
          listViews.add(
            GestureDetector(
              onTap: togetherId != null
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TogetherDetailScreen(
                            key: ValueKey('detail_$togetherId'),
                            togetherId: togetherId,
                          ),
                          settings: RouteSettings(name: '/together/$togetherId'),
                          fullscreenDialog: true,
                        ),
                      );
                    }
                  : null,
              child: RecentTogetherView(
                recentTogetherData: data,
                mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                        parent: widget.animationController!,
                        curve: Interval((1 / count) * 7, 1.0,
                            curve: Curves.fastOutSlowIn))),
                mainScreenAnimationController: widget.animationController!,
              ),
            ),
          );
        }
      }
    } catch (e) {
      List<StatisticsData> statisticsData = StatisticsData.getData(0, 0, 0, 0);

      listViews.add(
        TitleView(
          titleTxt: 'Statistics',
          subTxt: '',
          animation: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                  parent: widget.animationController!,
                  curve: Interval((1 / count) * 2, 1.0,
                      curve: Curves.fastOutSlowIn))),
          animationController: widget.animationController!,
        ),
      );

      listViews.add(
        StatisticsView(
          statisticsData: statisticsData,
          onNavigateToDrawerIndex: widget.onNavigateToDrawerIndex,
          mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                  parent: widget.animationController!,
                  curve: Interval((1 / count) * 3, 1.0,
                      curve: Curves.fastOutSlowIn))),
          mainScreenAnimationController: widget.animationController,
        ),
      );

      listViews.add(
        NoticeView(
            noticeText: "Network Error",
            animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                    parent: widget.animationController!,
                    curve: Interval((1 / count) * 8, 1.0,
                        curve: Curves.fastOutSlowIn))),
            animationController: widget.animationController!),
      );

      listViews.add(
        TitleView(
          titleTxt: 'Recent Together Top 3',
          subTxt: '',
          animation: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                  parent: widget.animationController!,
                  curve: Interval((1 / count) * 4, 1.0,
                      curve: Curves.fastOutSlowIn))),
          animationController: widget.animationController!,
        ),
      );
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HomeTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[
            getMainListViewUI(),
            getAppBarUI(),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            )
          ],
        ),
      ),
    );
  }

  Widget getMainListViewUI() {
    return FutureBuilder<bool>(
      future: getData(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        } else {
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.only(
              top: AppBar().preferredSize.height +
                  MediaQuery.of(context).padding.top +
                  AppTheme.paddingScreen,
              bottom: AppTheme.paddingScreen + MediaQuery.of(context).padding.bottom,
            ),
            itemCount: listViews.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              widget.animationController?.forward();
              return listViews[index];
            },
          );
        }
      },
    );
  }

  void goMemo() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const MemoScreen()));
  }

  Future<bool> _isLoggedIn() async {
    final storage = FlutterSecureStorage();
    final nickname = await storage.read(key: 'NICK_NAME');
    return nickname != null && nickname.isNotEmpty;
  }

  Widget getAppBarUI() {
    return Column(
      children: <Widget>[
        AnimatedBuilder(
          animation: widget.animationController!,
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: topBarAnimation!,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 30 * (1.0 - topBarAnimation!.value), 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: HomeTheme.white.withOpacity(topBarOpacity),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(AppTheme.radiusXl),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: HomeTheme.grey.withOpacity(0.06 * topBarOpacity),
                        offset: const Offset(0, 2),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).padding.top,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: AppTheme.paddingScreen,
                            right: AppTheme.paddingScreen,
                            top: 14 - 6.0 * topBarOpacity,
                            bottom: 14 - 6.0 * topBarOpacity),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                'GoTogether',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: HomeTheme.fontName,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20 + 4 - 4 * topBarOpacity,
                                  letterSpacing: 0.5,
                                  color: HomeTheme.darkerText,
                                ),
                              ),
                            ),
                            FutureBuilder<bool>(
                              future: _isLoggedIn(),
                              builder: (context, snapshot) {
                                if (snapshot.data == true) {
                                  return Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: goMemo,
                                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Icon(
                                          FontAwesomeIcons.envelope,
                                          size: 20,
                                          color: HomeTheme.dark_grey,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }
}
