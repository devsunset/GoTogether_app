class PostListItem {
  final int? postId;
  final String? category;
  final String? title;
  final String? content;
  final String? createdDate;
  final String? modifiedDate;
  final String? nickname;
  final String? username;
  final int? hit;
  final int? comment_count;

  PostListItem({
    this.postId,
    this.category,
    this.title,
    this.content,
    this.createdDate,
    this.modifiedDate,
    this.nickname,
    this.username,
    this.hit,
    this.comment_count,
  });

  factory PostListItem.fromJson(Map<String, dynamic> json) {
    return PostListItem(
      postId: json['postId'] as int?,
      category: json['category'] as String?,
      title: json['title'] as String?,
      content: json['content'] as String?,
      createdDate: json['createdDate'] as String?,
      modifiedDate: json['modifiedDate'] as String?,
      nickname: json['nickname'] as String?,
      username: json['username'] as String?,
      hit: json['hit'] as int?,
      comment_count: json['comment_count'] as int?,
    );
  }
}

class PostListPage {
  final List<PostListItem> content;
  final int totalPages;
  final int totalElements;
  final int number;
  final int size;

  PostListPage({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.number,
    required this.size,
  });

  factory PostListPage.fromJson(Map<String, dynamic> json) {
    final contentList = json['content'] as List<dynamic>? ?? [];
    return PostListPage(
      content: contentList.map((e) => PostListItem.fromJson(e as Map<String, dynamic>)).toList(),
      totalPages: json['totalPages'] as int? ?? 0,
      totalElements: json['totalElements'] as int? ?? 0,
      number: json['number'] as int? ?? 0,
      size: json['size'] as int? ?? 10,
    );
  }
}
