class HomeData {
  HomeData({
    this.imagePath = '',
    this.titleTxt = '',
    this.startColor = '',
    this.endColor = '',
    this.legend,
    this.count = 0,
  });

  String imagePath;
  String titleTxt;
  String startColor;
  String endColor;
  List<String>? legend;
  int count;

  static List<HomeData> tabIconsList = <HomeData>[
    HomeData(
      imagePath: 'assets/home/together.png',
      titleTxt: 'Together',
      count: 1,
      legend: <String>['More info.'],
      startColor: '#FFC107',
      endColor: '#FFC107',
    ),
    HomeData(
      imagePath: 'assets/home/together.png',
      titleTxt: 'Member',
      count: 2,
      legend: <String>['More info.'],
      startColor: '#17A2B8',
      endColor: '#17A2B8',
    ),
    HomeData(
      imagePath: 'assets/home/together.png',
      titleTxt: 'Talk',
      count: 3,
      legend: <String>['More info.'],
      startColor: '#28A745',
      endColor: '#28A745',
    ),
    HomeData(
      imagePath: 'assets/home/together.png',
      titleTxt: 'Q&A',
      count: 4,
      legend: <String>['More info.'],
      startColor: '#DC3545',
      endColor: '#DC3545',
    ),
  ];
}
