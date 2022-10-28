import 'dart:convert';
import 'package:http/http.dart' as http;
import 'model.dart';
class Api {

  Future<ForceUpdateModel?> getData(packageName) async {
    String url = "https://force-update.herokuapp.com/fu/get_pkg_by_appname";
    Uri uri = Uri.parse(url);
    print(url);
    Map<String,dynamic> _body={
      "app_name": packageName
    };
    http.Response res = await http.post(uri,body:_body); //network call

    print(res.body);
    if (res.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(res.body);
      ForceUpdateModel forceUpdateModel = ForceUpdateModel.fromJson(jsonData);
      return forceUpdateModel;
    }
    return null;
  }
}
Api api = Api();
