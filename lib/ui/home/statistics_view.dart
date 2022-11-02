import 'package:flutter/material.dart';
import 'package:gotogether/data/models/home/statistics_data.dart';
import 'package:gotogether/main.dart';
import 'package:gotogether/ui/home/home_theme.dart';
import 'package:gotogether/ui/member/member_screen.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView(
      {Key? key,
      this.mainScreenAnimationController,
      this.mainScreenAnimation,
      required this.statisticsData})
      : super(key: key);

  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;
  final List<StatisticsData> statisticsData;

  @override
  _StatisticsViewState createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView>
    with TickerProviderStateMixin {
  AnimationController? animationController;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  void goPage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => MemberScreen()));
  }


  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.mainScreenAnimationController!,
      builder: (BuildContext context, Widget? child) {
        List<StatisticsData> statisticsData = widget.statisticsData;
        return FadeTransition(
          opacity: widget.mainScreenAnimation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - widget.mainScreenAnimation!.value), 0.0),
            child: Container(
              height: 186,
              width: double.infinity,
              child: ListView.builder(
                padding: const EdgeInsets.only(
                    top: 0, bottom: 0, right: 16, left: 16),
                itemCount: statisticsData.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  final int count =
                      statisticsData.length > 10 ? 10 : statisticsData.length;
                  final Animation<double> animation =
                      Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                              parent: animationController!,
                              curve: Interval((1 / count) * index, 1.0,
                                  curve: Curves.fastOutSlowIn)));
                  animationController?.forward();

                  return ItemsView(
                    statisticsData: statisticsData[index],
                    animation: animation,
                    animationController: animationController!,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class ItemsView extends StatelessWidget {
  const ItemsView(
      {Key? key, this.statisticsData, this.animationController, this.animation})
      : super(key: key);

  final StatisticsData? statisticsData;
  final AnimationController? animationController;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                100 * (1.0 - animation!.value), 0.0, 0.0),
            child: SizedBox(
              width: 98,
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 32, left: 8, right: 8, bottom: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: HexColor(statisticsData!.endColor)
                                  .withOpacity(0.6),
                              offset: const Offset(1.1, 4.0),
                              blurRadius: 8.0),
                        ],
                        gradient: LinearGradient(
                          colors: <HexColor>[
                            HexColor(statisticsData!.startColor),
                            HexColor(statisticsData!.endColor),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(8.0),
                          bottomLeft: Radius.circular(8.0),
                          topLeft: Radius.circular(8.0),
                          topRight: Radius.circular(54.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 54, left: 16, right: 16, bottom: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              statisticsData!.titleTxt,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: HomeTheme.fontName,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 0.2,
                                color: HomeTheme.white,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 8, bottom: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      statisticsData!.legend!.join('\n'),
                                      style: TextStyle(
                                        fontFamily: HomeTheme.fontName,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 10,
                                        letterSpacing: 0.2,
                                        color: HomeTheme.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            statisticsData?.count != 0
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        statisticsData!.count.toString(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: HomeTheme.fontName,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 24,
                                          letterSpacing: 0.2,
                                          color: HomeTheme.white,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 4, bottom: 3),
                                        child: Text(
                                          '',
                                          style: TextStyle(
                                            fontFamily: HomeTheme.fontName,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 10,
                                            letterSpacing: 0.2,
                                            color: HomeTheme.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      color: HomeTheme.nearlyWhite,
                                      shape: BoxShape.circle,
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                            color: HomeTheme.nearlyBlack
                                                .withOpacity(0.4),
                                            offset: Offset(8.0, 8.0),
                                            blurRadius: 8.0),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Icon(
                                        Icons.add,
                                        color:
                                            HexColor(statisticsData!.endColor),
                                        size: 24,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: HomeTheme.nearlyWhite.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Positioned(
                  //   top: 0,
                  //   left: 8,
                  //   child: SizedBox(
                  //     width: 80,
                  //     height: 80,
                  //     child: Image.asset(homeListData!.imagePath),
                  //   ),
                  // )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
