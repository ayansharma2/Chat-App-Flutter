import 'package:flutter/cupertino.dart';

class Message {
  String sender, receiver, message, time;

  Message(
      {@required this.sender,
      @required this.receiver,
      @required this.message,
      @required this.time});

  Map<String, dynamic> toJson() {
    return {
      "sender": sender,
      "receiver": receiver,
      "message": message,
      "time": time
    };
  }

  Message.fromJson(Map<String, Object> json)
      : this(
            sender: json['sender'] as String,
            receiver: json['receiver'] as String,
            message: json['message'] as String,
            time: json['timer'] as String);
}
