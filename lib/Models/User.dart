import 'dart:core';

import 'package:flutter/foundation.dart';


class User {
  String id,name,profilePic;
  User({@required this.id, @required this.name,@required this.profilePic});

  User.fromJson(Map<String, Object> json):this(
    id:json['id'] as String,
    name:json['name'] as String,
    profilePic:json['profilePic'] as String
  );

  Map<String,Object> toJson(){
    return{
      'id':id,
      'name':name,
      'profilePic':profilePic
    };
  }

  String toString(){
    return "User \n id:${this.id}\n name:${this.name}\n profilePic:${this.profilePic}";
  }
}