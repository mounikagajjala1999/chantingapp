class ForceUpdateModel {
  int? code;
  int? count;
  String? message;
  List<Result>? result;

  ForceUpdateModel({this.code, this.count, this.message, this.result});

  ForceUpdateModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    count = json['count'];
    message = json['message'];
    if (json['result'] != null) {
      result = <Result>[];
      json['result'].forEach((v) {
        result!.add(new Result.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['count'] = this.count;
    data['message'] = this.message;
    if (this.result != null) {
      data['result'] = this.result!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Result {
  String? sId;
  String? appName;
  String? appVersion;
  String? appBuild;

  Result({this.sId, this.appName, this.appVersion, this.appBuild});

  Result.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    appName = json['app_name'];
    appVersion = json['app_version'];
    appBuild = json['app_build'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['app_name'] = this.appName;
    data['app_version'] = this.appVersion;
    data['app_build'] = this.appBuild;
    return data;
  }
}