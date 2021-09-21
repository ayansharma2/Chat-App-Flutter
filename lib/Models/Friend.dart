import 'package:flutter/cupertino.dart';

class Friend {
  String id;

  Friend({@required this.id});
  Map<String,Object> toJson(){
    return{
      'id':id
    };
  }


  Friend.fromJson(Map<String, Object> json):this(
    id:json['id'] as String
  );
}
