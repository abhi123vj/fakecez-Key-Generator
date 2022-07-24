import 'dart:developer';
import 'package:fakecez_key_gen/networks/app_urls.dart';
import 'package:fakecez_key_gen/networks/dio.dart';
class Repo {
  static Future<String> userSignUp() async {
    try {
      final response = await dio.get(ApiUrl.keyGen);
      
      if(response.data!=''){
      String str = response.data.toString();
      const start = "color=lime>";
      const end = "<div>";

      final startIndex = str.indexOf(start);
      final endIndex = str.indexOf(end, startIndex + start.length);

      String key = str.substring(startIndex + start.length, endIndex);
      return key;
      }else{
        return "Error!Try Again?";
      }
      
    } catch (error) {
     
      return "Error!Try Again?";
    }
  }
}

//html/body/center/font/font/center/div/font/text()
///html/body/center/font/font/center/div/font