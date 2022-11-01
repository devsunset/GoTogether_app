class DataModel {
  int? status;
  String? result;
  String? code;
  String? error;
  String? message;
  String? description;
  String? timestamp;
  Map<String, dynamic>? data;

  DataModel({this.status, this.result, this.code, this.error, this.message, this.description, this.timestamp, this.data});

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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['result'] = result;
    data['code'] = code;
    data['error'] = error;
    data['message'] = message;
    data['description'] = description;
    data['timestamp'] = timestamp;
    data['data'] = data;
    return data;
  }
}
