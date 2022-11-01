import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gotogether/data/di/service_locator.dart';
import 'package:gotogether/data/models/home/statistics_data.dart';
import 'package:gotogether/ui/home/home_theme.dart';
import 'package:gotogether/ui/home/notice_view.dart';
import 'package:gotogether/ui/home/recent_together_view.dart';
import 'package:gotogether/ui/home/statistics_view.dart';
import 'package:gotogether/ui/home/title_view.dart';

import '../../data/models/datat_model.dart';
import '../../data/models/home/recent_together_data.dart';
import 'home_controller.dart';

class LayoutScreen extends StatefulWidget {
  const LayoutScreen({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;
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

      List<StatisticsData> statisticsData = StatisticsData.getData(
          int.parse(dataModel.data?['TOGETHER']),
          int.parse(dataModel.data?['USER']),
          int.parse(dataModel.data?['TALK']),
          int.parse(dataModel.data?['QA']));

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
            noticeText: dataModel.data?['NOTICE'],
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

      final recentTogetherDataList =
          (dataModel.data?['RECENT_TOGETHER'] as List)
              .map((e) => RecentTogetherData.fromJson(e))
              .toList();

      if (recentTogetherDataList.length > 0) {
        for (int i = 0; i < recentTogetherDataList.length; i++) {
          listViews.add(
            RecentTogetherView(
              recentTogetherData: recentTogetherDataList[i],
              mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                      parent: widget.animationController!,
                      curve: Interval((1 / count) * 7, 1.0,
                          curve: Curves.fastOutSlowIn))),
              mainScreenAnimationController: widget.animationController!,
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
                  25,
              bottom: 25 + MediaQuery.of(context).padding.bottom,
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
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color:
                              HomeTheme.grey.withOpacity(0.4 * topBarOpacity),
                          offset: const Offset(1.1, 1.1),
                          blurRadius: 10.0),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).padding.top,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16 - 8.0 * topBarOpacity,
                            bottom: 12 - 8.0 * topBarOpacity),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Text(
                                  '         GoTogether',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: HomeTheme.fontName,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22 + 6 - 6 * topBarOpacity,
                                    letterSpacing: 1.2,
                                    color: HomeTheme.darkerText,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: AppBar().preferredSize.height,
                              height: AppBar().preferredSize.height,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(0.0),
                                      ),
                                      onTap: () {},
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(FontAwesomeIcons.envelope),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
