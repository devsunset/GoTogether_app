/// 백엔드 공통 응답 래퍼.
/// status, result, code, message 등과 함께 data에 실제 페이로드를 담는다.
class DataModel {
  int? status;
  String? result;
  String? code;
  String? error;
  String? message;
  String? description;
  String? timestamp;
  Map<String, dynamic>? data;

  DataModel({
    this.status,
    this.result,
    this.code,
    this.error,
    this.message,
    this.description,
    this.timestamp,
    this.data,
  });

  DataModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    result = json['result'];
    code = json['code'];
    error = json['error'];
    message = json['message'];
    description = json['description'];
    timestamp = json['timestamp'];
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['status'] = status;
    map['result'] = result;
    map['code'] = code;
    map['error'] = error;
    map['message'] = message;
    map['description'] = description;
    map['timestamp'] = timestamp;
    map['data'] = data;
    return map;
  }
}
