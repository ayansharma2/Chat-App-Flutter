import 'package:chat_app/Activity/SignIn.dart';
import 'package:chat_app/Models/LatestMessage.dart';
import 'package:chat_app/Models/Message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/Models/User.dart' as localUser;
import 'package:google_fonts/google_fonts.dart';
import 'package:indexed_list_view/indexed_list_view.dart';

class ChatActivity extends StatefulWidget {
  final localUser.User friend;

  const ChatActivity(
    this.friend, {
    Key key,
  }) : super(key: key);

  @override
  _ChatActivityState createState() => _ChatActivityState(friend);
}

class _ChatActivityState extends State<ChatActivity> {
  localUser.User friend;
  _ChatActivityState(this.friend);
  var messages=[];
  var _controller=ScrollController();
@override
  void initState() {
  FirebaseFirestore.instance.collection("Users").doc(FirebaseAuth.instance.currentUser.uid)
      .collection("Messages").doc(friend.id).collection("Messages").orderBy("time").snapshots()
  .listen((event) {
    event.docChanges.forEach((element) {
      if(element.type==DocumentChangeType.added){
        print(element.doc.data());
        messages.add(Message.fromJson(element.doc.data()));
        setState(() {});
      }
    });
    _controller.jumpTo(_controller.position.maxScrollExtent);
    setState(() {});
  });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.purple,
        leadingWidth: 50,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new),
        ),
        title: Row(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 15, 0),
              width: 40,
              height: 40,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(friend.profilePic),
              ),
            ),
            Text(
              friend.name,
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Flexible(
            child: messageBody(),
            flex: 1,
          ),
          chatBottom()
        ],
      ),
    );
  }

  Widget messageBody() {
    if(messages.isEmpty){
      return Container(
        alignment: Alignment.center,
        child: Text("No Messages Currently",style: GoogleFonts.montserrat(color: Colors.purple,fontSize: 20),),
      );
    }else{
      return Container(
        alignment: Alignment.bottomCenter,
        child: ListView.builder(
          controller: _controller,
          shrinkWrap: true,
            itemCount: messages.length,
            itemBuilder: (context,index){
              return messageTile(messages[index]);
            }),
      );
    }
  }

  Widget messageTile(Message message){
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: (message.sender==FirebaseAuth.instance.currentUser.uid) ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.purple,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(15)
        ),
        margin: EdgeInsets.fromLTRB(0, 1.5, 3, 1.5),
        child: Padding(
          padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
          child: Text(message.message,style: GoogleFonts.montserrat(color: Colors.white),),
        ),
      ),
    );
  }

  var messageController = TextEditingController();

  Widget chatBottom() {
    return Row(
      children: [
        Flexible(
          child: Container(
              margin: EdgeInsets.fromLTRB(9, 0, 0, 5),
              height: 50,
              child: TextField(
                controller: messageController,
                  onChanged: (message) {
                    messageController.text = message;
                    messageController.selection = TextSelection.fromPosition(
                        TextPosition(offset: messageController.text.length));
                    setState(() {});
                  },
                  decoration: InputDecoration(
                      hintText: "Enter Your message here",
                      hintStyle: TextStyle(color: Colors.white),
                      fillColor: Colors.purple,
                      filled: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50))),
                  cursorColor: Colors.white,
                  style: TextStyle(color: Colors.white))),
          flex: 1,
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30), color: Colors.purple),
          margin: EdgeInsets.fromLTRB(5, 0, 9, 0),
          child: IconButton(
            icon: Icon(
              Icons.send,
              color: Colors.white,
            ),
            onPressed: () => sendMessage(messageController.text),
          ),
        )
      ],
    );
  }

  void sendMessage(String text) {
    if(text.trim().isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(createSnackBar("Enter a valid Message"));
      return;
    }
    var fireStore = FirebaseFirestore.instance;
    var uid = FirebaseAuth.instance.currentUser.uid;
    var message = Message(
        sender: uid,
        receiver: friend.id,
        message: text,
        time: DateTime.now().toString());
    fireStore
        .collection("Users")
        .doc(uid)
        .collection("Messages")
        .doc(friend.id)
        .collection("Messages")
        .add(message.toJson())
        .then((value) {
      fireStore
          .collection("Users")
          .doc(friend.id)
          .collection("Messages")
          .doc(uid)
          .collection("Messages")
          .add(message.toJson())
          .then((value) {
        setState(() {
          messageController.text = "";
          _controller.jumpTo(_controller.position.maxScrollExtent);
        });
        updateTime(fireStore,uid);
      });
    });
  }

  void updateTime(FirebaseFirestore fireStore, String uid) {
    var latestMessage=LatestMessage(userId: friend.id, time: DateTime.now().toString());
    fireStore.collection("Users").doc(uid).collection("Latest Messages")
        .doc(friend.id).set(latestMessage.toJson())
    .then((value){
      latestMessage.userId=uid;
      fireStore.collection("Users").doc(friend.id).collection("Latest Messages").doc(uid).set(latestMessage.toJson());
    });
  }
}
