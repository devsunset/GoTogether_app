class MemoListItem {
  final int? memoId;
  final String? memo;
  final String? createdDate;
  final String? modifiedDate;
  final String? readflag;
  final String? senderUsername;
  final String? senderNickname;
  final String? receiverUsername;
  final String? receiverNickname;

  MemoListItem({
    this.memoId,
    this.memo,
    this.createdDate,
    this.modifiedDate,
    this.readflag,
    this.senderUsername,
    this.senderNickname,
    this.receiverUsername,
    this.receiverNickname,
  });

  factory MemoListItem.fromJson(Map<String, dynamic> json) {
    return MemoListItem(
      memoId: json['memoId'] as int?,
      memo: json['memo'] as String?,
      createdDate: json['createdDate'] as String?,
      modifiedDate: json['modifiedDate'] as String?,
      readflag: json['readflag'] as String?,
      senderUsername: json['senderUsername'] as String?,
      senderNickname: json['senderNickname'] as String?,
      receiverUsername: json['receiverUsername'] as String?,
      receiverNickname: json['receiverNickname'] as String?,
    );
  }
}

class MemoListPage {
  final List<MemoListItem> content;
  final int totalPages;
  final int totalElements;
  final int number;
  final int size;

  MemoListPage({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.number,
    required this.size,
  });

  factory MemoListPage.fromJson(Map<String, dynamic> json) {
    final raw = json['content'];
    final List<dynamic> contentList = raw is List ? raw : [];
    return MemoListPage(
      content: contentList.map((e) => MemoListItem.fromJson(e is Map<String, dynamic> ? e : {})).toList(),
      totalPages: json['totalPages'] as int? ?? 0,
      totalElements: json['totalElements'] as int? ?? 0,
      number: json['number'] as int? ?? 0,
      size: json['size'] as int? ?? 10,
    );
  }
}
