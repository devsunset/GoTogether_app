class TogetherListItem {
  final int? togetherId;
  final String? title;
  final String? category;
  final String? content;
  final String? involveType;
  final String? openKakaoChat;
  final int? hit;
  final int? currentMember;
  final int? maxMember;
  final int? progress;
  final String? progressLegend;
  final String? skill;
  final int? togetherComment_count;
  final String? createdDate;
  final String? modifiedDate;
  final String? nickname;
  final String? username;

  TogetherListItem({
    this.togetherId,
    this.title,
    this.category,
    this.content,
    this.involveType,
    this.openKakaoChat,
    this.hit,
    this.currentMember,
    this.maxMember,
    this.progress,
    this.progressLegend,
    this.skill,
    this.togetherComment_count,
    this.createdDate,
    this.modifiedDate,
    this.nickname,
    this.username,
  });

  factory TogetherListItem.fromJson(Map<String, dynamic> json) {
    return TogetherListItem(
      togetherId: json['togetherId'] as int?,
      title: json['title'] as String?,
      category: json['category'] as String?,
      content: json['content'] as String?,
      involveType: json['involveType'] as String?,
      openKakaoChat: json['openKakaoChat'] as String?,
      hit: json['hit'] as int?,
      currentMember: json['currentMember'] as int?,
      maxMember: json['maxMember'] as int?,
      progress: json['progress'] as int?,
      progressLegend: json['progressLegend'] as String?,
      skill: json['skill'] as String?,
      togetherComment_count: json['togetherComment_count'] as int?,
      createdDate: json['createdDate'] as String?,
      modifiedDate: json['modifiedDate'] as String?,
      nickname: json['nickname'] as String?,
      username: json['username'] as String?,
    );
  }
}

class TogetherListPage {
  final List<TogetherListItem> content;
  final int totalPages;
  final int totalElements;
  final int number;
  final int size;

  TogetherListPage({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.number,
    required this.size,
  });

  factory TogetherListPage.fromJson(Map<String, dynamic> json) {
    final List<dynamic> contentList = json['content'] ?? [];
    return TogetherListPage(
      content: contentList.map((e) => TogetherListItem.fromJson(e as Map<String, dynamic>)).toList(),
      totalPages: json['totalPages'] as int? ?? 0,
      totalElements: json['totalElements'] as int? ?? 0,
      number: json['number'] as int? ?? 0,
      size: json['size'] as int? ?? 10,
    );
  }
}
