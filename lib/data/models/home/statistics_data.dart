class StatisticsData {
  StatisticsData({
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

  static List<StatisticsData> getData(int a, int b, int c, int d) {
    return <StatisticsData>[
      StatisticsData(
        imagePath: 'assets/home/together.png',
        titleTxt: 'Together',
        count: a,
        legend: <String>['More info.'],
        startColor: '#FFC107',
        endColor: '#FFC107',
      ),
      StatisticsData(
        imagePath: 'assets/home/together.png',
        titleTxt: 'Member',
        count: b,
        legend: <String>['More info.'],
        startColor: '#17A2B8',
        endColor: '#17A2B8',
      ),
      StatisticsData(
        imagePath: 'assets/home/together.png',
        titleTxt: 'Talk',
        count: c,
        legend: <String>['More info.'],
        startColor: '#28A745',
        endColor: '#28A745',
      ),
      StatisticsData(
        imagePath: 'assets/home/together.png',
        titleTxt: 'Q&A',
        count: d,
        legend: <String>['More info.'],
        startColor: '#DC3545',
        endColor: '#DC3545',
      ),
    ];
  }
}
