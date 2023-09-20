import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class BookMarkProvider extends ChangeNotifier{

  List bookmark = [];

  void addToBookMark(Map map){
    bookmark.add(map);
    notifyListeners();
    setSp();
  }

  void setSp()async{
    sp=await SharedPreferences.getInstance();
    sp.setString('bookmark', jsonEncode(bookmark));
  }

  void getSp()async{
    sp=await SharedPreferences.getInstance();
    String sharePref = sp.getString('bookmark')??'';
    bookmark = jsonDecode(sharePref);
    notifyListeners();
  }

  void removeFromBookMark(int index){
    bookmark.removeAt(index);
    notifyListeners();
    setSp();
  }

}