import 'dart:convert';

import 'package:http/http.dart' as http;

import 'model.dart';


class Api {
  Future<ForceUpdateModel?> getData(version) async {
    String url = "https://force-update.onrender.com/fu/get_pkgs";
    Uri uri = Uri.parse(url);
    print(url);
    http.Response res = await http.get(uri); //network call

    print(res.body);
    if (res.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(res.body);
      ForceUpdateModel? model = ForceUpdateModel.fromJson(jsonData);
      return model;
    }
    return null;
  }
}
Api apiget =Api();