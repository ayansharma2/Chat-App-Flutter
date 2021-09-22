

import 'package:flutter/cupertino.dart';

class LatestMessage{
  String userId,time;
  LatestMessage({@required this.userId, @required this.time});


  LatestMessage.fromJson(Map<String, Object> json):this(
    userId:json['userId'] as String,
    time:json['time'] as String
  );


  Map<String,Object> toJson(){
    return{
      'userId':userId,
      'time':time
    };
  }
}