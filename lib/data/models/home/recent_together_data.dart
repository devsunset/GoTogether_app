class RecentTogetherData {

  int? togetherId;
  String? title;
  String? nickname;
  String? createdDate;
  int? hit;
  int? togetherComment_count;
  int? progress;

  RecentTogetherData({this.togetherId,this.title, this.nickname, this.createdDate, this.hit, this.togetherComment_count,this.progress});

  RecentTogetherData.fromJson(Map<String, dynamic> json) {
    togetherId = json['togetherId'];
    title = json['title'];
    nickname = json['nickname'];
    createdDate = json['createdDate'];
    hit = json['hit'];
    togetherComment_count = json['togetherComment_count'];
    progress = json['progress'];
  }
}
