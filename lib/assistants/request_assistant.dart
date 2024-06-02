import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class RequestAssistant{

  static Future<dynamic> recieveRequest(String url) async{
    
    http.Response httpResponse = await http.get(Uri.parse(url));

    try{
      if(httpResponse.statusCode == 200){
        String responceData = httpResponse.body;
        var decodeResponceData = jsonDecode(responceData);
        return decodeResponceData;
      }
      else{
        return "Error Occured : failed No Responce";
      }
    }catch(exp){
      return "Error Occured : failed No Responce";
    }
    
  }

}