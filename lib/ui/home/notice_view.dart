/// 홈 공지 영역. Vue Home 공지와 동일.
import 'package:flutter/material.dart';
import 'package:gotogether/main.dart';
import 'package:gotogether/ui/app_theme.dart';
import 'package:gotogether/ui/home/home_theme.dart';

class NoticeView extends StatelessWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;
  final String noticeText;

  const NoticeView(
      {Key? key, this.noticeText = "", this.animationController, this.animation})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - animation!.value), 0.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                      left: AppTheme.paddingScreen,
                      right: AppTheme.paddingScreen,
                      top: 0,
                      bottom: 24),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: AppTheme.paddingCard),
                        child: Container(
                          decoration: BoxDecoration(
                            color: HomeTheme.nearlyBlue.withOpacity(0.12),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(AppTheme.radiusSm),
                                bottomLeft: Radius.circular(AppTheme.radiusSm),
                                bottomRight: Radius.circular(AppTheme.radiusSm),
                                topRight: Radius.circular(AppTheme.radiusSm)),
                            // boxShadow: <BoxShadow>[
                            //   BoxShadow(
                            //       color: FitnessAppTheme.grey.withOpacity(0.2),
                            //       offset: Offset(1.1, 1.1),
                            //       blurRadius: 10.0),
                            // ],
                          ),
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 68, bottom: 12, right: 16, top: 12),
                                child: Text(
                                  // '함께 공부해요 ^^',
                                  noticeText,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: HomeTheme.fontName,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    letterSpacing: 0.0,
                                    color: HomeTheme.nearlyDarkBlue
                                        .withOpacity(0.6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: -12,
                        left: 0,
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.asset("assets/home/bell.png"),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
