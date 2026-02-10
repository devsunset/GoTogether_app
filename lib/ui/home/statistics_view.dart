/// 홈 통계 카드 4개(Together/Member/Talk/Q&A). 탭 시 해당 메뉴로 이동. Vue와 동일.
import 'package:flutter/material.dart';
import 'package:gotogether/data/models/home/statistics_data.dart';
import 'package:gotogether/main.dart';
import 'package:gotogether/ui/custom_drawer/home_drawer.dart';
import 'package:gotogether/ui/app_theme.dart';
import 'package:gotogether/ui/home/home_theme.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView(
      {Key? key,
      this.mainScreenAnimationController,
      this.mainScreenAnimation,
      this.onNavigateToDrawerIndex,
      required this.statisticsData})
      : super(key: key);

  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;
  final void Function(DrawerIndex)? onNavigateToDrawerIndex;
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // 화면비율에 맞게: 4개 카드가 한 줄에 보이도록 카드 너비 계산 (좌우 16 + 카드 간 8)
    final horizontalPadding = AppTheme.paddingCard;
    const gap = 8.0;
    const cardCount = 4;
    final cardWidth = ((screenWidth - horizontalPadding * 2 - gap * (cardCount - 1)) / cardCount).clamp(100.0, 165.0);
    final containerHeight = (cardWidth * (186 / 98)).clamp(190.0, 320.0);

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
              height: containerHeight,
              width: double.infinity,
              child: ListView.builder(
                padding: EdgeInsets.only(
                    top: 0, bottom: 0, right: horizontalPadding, left: horizontalPadding),
                itemCount: statisticsData.length,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
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

                  return Padding(
                    padding: EdgeInsets.only(right: index < statisticsData.length - 1 ? gap : 0),
                    child: ItemsView(
                      statisticsData: statisticsData[index],
                      onNavigateToDrawerIndex: widget.onNavigateToDrawerIndex,
                      animation: animation,
                      animationController: animationController!,
                      cardWidth: cardWidth,
                      cardHeight: containerHeight,
                    ),
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
      {Key? key,
      this.statisticsData,
      this.onNavigateToDrawerIndex,
      this.animationController,
      this.animation,
      this.cardWidth = 98,
      this.cardHeight = 186})
      : super(key: key);

  final StatisticsData? statisticsData;
  final void Function(DrawerIndex)? onNavigateToDrawerIndex;
  final AnimationController? animationController;
  final Animation<double>? animation;
  final double cardWidth;
  final double cardHeight;

  static DrawerIndex? _drawerIndexForTitle(String? title) {
    switch (title?.toLowerCase()) {
      case 'together':
        return DrawerIndex.TOGETHER;
      case 'member':
        return DrawerIndex.MEMBER;
      case 'talk':
        return DrawerIndex.POST_TALK;
      case 'q&a':
        return DrawerIndex.POST_QA;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        final idx = _drawerIndexForTitle(statisticsData?.titleTxt);
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                100 * (1.0 - animation!.value), 0.0, 0.0),
            child: InkWell(
              onTap: idx != null && onNavigateToDrawerIndex != null
                  ? () => onNavigateToDrawerIndex!(idx)
                  : null,
              child: SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          top: cardWidth * 0.33,
                          left: cardWidth * 0.08,
                          right: cardWidth * 0.08,
                          bottom: cardWidth * 0.16),
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
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(AppTheme.radiusSm * (cardWidth / 98)),
                            bottomLeft: Radius.circular(AppTheme.radiusSm * (cardWidth / 98)),
                            topLeft: Radius.circular(AppTheme.radiusSm * (cardWidth / 98)),
                            topRight: Radius.circular(54.0 * (cardWidth / 98)),
                          ),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final scale = cardWidth / 98;
                            final titleSize = (12 * scale).clamp(12.0, 16.0);
                            final legendSize = (11 * scale).clamp(10.0, 14.0);
                            final countSize = (24 * scale).clamp(20.0, 32.0);
                            return Padding(
                              padding: EdgeInsets.only(
                                  top: 54 * scale,
                                  left: 16 * scale,
                                  right: 16 * scale,
                                  bottom: 8 * scale),
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
                                      fontSize: titleSize,
                                      letterSpacing: 0.2,
                                      color: HomeTheme.white,
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          top: 8 * scale, bottom: 8 * scale),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            statisticsData!.legend!.join('\n'),
                                            style: TextStyle(
                                              fontFamily: HomeTheme.fontName,
                                              fontWeight: FontWeight.w500,
                                              fontSize: legendSize,
                                              letterSpacing: 0.2,
                                              color: HomeTheme.white,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
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
                                                fontSize: countSize,
                                                letterSpacing: 0.2,
                                                color: HomeTheme.white,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 4 * scale, bottom: 3 * scale),
                                              child: Text(
                                                '',
                                                style: TextStyle(
                                                  fontFamily: HomeTheme.fontName,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: legendSize,
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
                                                  color: HomeTheme.nearlyBlack.withOpacity(0.4),
                                                  offset: Offset(8.0, 8.0),
                                                  blurRadius: 8.0),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(6.0 * scale),
                                            child: Icon(
                                              Icons.add,
                                              color: HexColor(statisticsData!.endColor),
                                              size: 24 * scale,
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        width: 84 * (cardWidth / 98),
                        height: 84 * (cardWidth / 98),
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
          ),
        );
      },
    );
  }
}
