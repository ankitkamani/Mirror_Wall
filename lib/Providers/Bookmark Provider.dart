import 'package:flutter/material.dart';

class BookMarkProvider extends ChangeNotifier{

  List<Map<String, String>> bookmark = [];

  void addToBookMark(Map<String,String> map){
    bookmark.add(map);
    notifyListeners();
  }

  void removeFromBookMark(int index){
    bookmark.removeAt(index);
    notifyListeners();
  }

}