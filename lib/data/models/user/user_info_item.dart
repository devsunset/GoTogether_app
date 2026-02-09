class UserInfoItem {
  final int? userInfoId;
  final String? introduce;
  final String? note;
  final String? github;
  final String? homepage;
  final String? skill;
  final String? createdDate;
  final String? modifiedDate;
  final String? nickname;
  final String? username;

  UserInfoItem({
    this.userInfoId,
    this.introduce,
    this.note,
    this.github,
    this.homepage,
    this.skill,
    this.createdDate,
    this.modifiedDate,
    this.nickname,
    this.username,
  });

  factory UserInfoItem.fromJson(Map<String, dynamic> json) {
    return UserInfoItem(
      userInfoId: json['userInfoId'] as int?,
      introduce: json['introduce'] as String?,
      note: json['note'] as String?,
      github: json['github'] as String?,
      homepage: json['homepage'] as String?,
      skill: json['skill'] as String?,
      createdDate: json['createdDate'] as String?,
      modifiedDate: json['modifiedDate'] as String?,
      nickname: json['nickname'] as String?,
      username: json['username'] as String?,
    );
  }
}

class UserInfoListPage {
  final List<UserInfoItem> content;
  final int totalPages;
  final int totalElements;
  final int number;
  final int size;

  UserInfoListPage({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.number,
    required this.size,
  });

  factory UserInfoListPage.fromJson(Map<String, dynamic> json) {
    final contentList = json['content'] as List<dynamic>? ?? [];
    return UserInfoListPage(
      content: contentList.map((e) => UserInfoItem.fromJson(e as Map<String, dynamic>)).toList(),
      totalPages: json['totalPages'] as int? ?? 0,
      totalElements: json['totalElements'] as int? ?? 0,
      number: json['number'] as int? ?? 0,
      size: json['size'] as int? ?? 10,
    );
  }
}
