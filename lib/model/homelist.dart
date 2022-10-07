import 'package:gotogether/home/home_screen.dart';
import 'package:gotogether/hotel_booking/hotel_home_screen.dart';
import 'package:flutter/widgets.dart';

class HomeList {
  HomeList({
    this.navigateScreen,
    this.imagePath = '',
  });

  Widget? navigateScreen;
  String imagePath;

  static List<HomeList> homeList = [
    HomeList(
      imagePath: 'assets/home/fitness_app.png',
      navigateScreen: HomeScreen(),
    ),
    HomeList(
      imagePath: 'assets/hotel/hotel_booking.png',
      navigateScreen: HotelHomeScreen(),
    ),
    HomeList(
      imagePath: 'assets/home/fitness_app.png',
      navigateScreen: HomeScreen(),
    ),
    HomeList(
      imagePath: 'assets/home/fitness_app.png',
      navigateScreen: HomeScreen(),
    ),
  ];
}
