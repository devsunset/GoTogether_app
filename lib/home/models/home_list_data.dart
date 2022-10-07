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
      startColor: '#FA7D82',
      endColor: '#FFB295',
    ),
    HomeData(
      imagePath: 'assets/home/together.png',
      titleTxt: 'Member',
      count: 2,
      legend: <String>['More info.'],
      startColor: '#738AE6',
      endColor: '#5C5EDD',
    ),
    HomeData(
      imagePath: 'assets/home/together.png',
      titleTxt: 'Talk',
      count: 3,
      legend: <String>['More info.'],
      startColor: '#FE95B6',
      endColor: '#FF5287',
    ),
    HomeData(
      imagePath: 'assets/home/together.png',
      titleTxt: 'Q&A',
      count: 4,
      legend: <String>['More info.'],
      startColor: '#6F72CA',
      endColor: '#1E1466',
    ),
  ];
}
