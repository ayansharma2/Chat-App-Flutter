import 'package:chat_app/Activity/ChatActivity.dart';
import 'package:chat_app/Activity/SignIn.dart';
import 'package:chat_app/Models/Friend.dart';
import 'package:chat_app/Models/LatestMessage.dart';
import 'package:chat_app/Models/Message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chat_app/Models/User.dart' as localUser;
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

var friends = [];
final friendNameController = TextEditingController();

class _HomeState extends State<Home> with TickerProviderStateMixin {
  bool isSearchClicked = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.purple,
        title: Text(
          "You Chat",
          style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              isSearchClicked = !isSearchClicked;
              setState(() {});
            },
            child: Container(
              margin: EdgeInsets.only(right: 10),
              child: Icon(
                  (isSearchClicked) ? Icons.arrow_back_ios_new : Icons.search),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          getBody(),
        ],
      ),
    );
  }

  Widget getBody() {
    if (isSearchClicked) {
      return topTextField(context);
    } else {
      return Expanded(child: tabLayout());
    }
  }

  Widget topTextField(BuildContext context) {
    return new Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(color: Colors.purple),
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: TextField(
            controller: friendNameController,
            onChanged: (name) {
              friendNameController.text = name;
              friendNameController.selection = TextSelection.fromPosition(
                  TextPosition(offset: friendNameController.text.length));
              setState(() {});
            },
            decoration: InputDecoration(
                labelText: "Search your Friend",
                labelStyle: TextStyle(color: Colors.purple),
                fillColor: Colors.white,
                filled: true,
                border: InputBorder.none),
            cursorColor: Colors.purple,
            style: TextStyle(color: Colors.black),
          ),
        ),
        searchResults(),
      ],
    );
  }

  Widget searchResults() {
    print("Names ${friendNameController.text}");
    if (friendNameController.text.isEmpty) {
      return Container(
        margin: EdgeInsets.fromLTRB(0, 300, 0, 0),
        child: Text(
          "Search new Friends",
          style: GoogleFonts.montserrat(color: Colors.purple, fontSize: 20),
        ),
      );
    } else {
      return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("Users")
              .where('name', isGreaterThanOrEqualTo: friendNameController.text)
              .where('name', isLessThan: friendNameController.text + 'z')
              .limit(20)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData) {
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: streamSnapshot.data.docs.length,
                  itemBuilder: (_, index) {
                    var user = localUser.User.fromJson(
                        streamSnapshot.data.docs[index].data());
                    return userCard(user, context, true);
                  });
            } else {
              return new Container();
            }
          });
    }
  }
}

Widget tabLayout() {
  return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(double.infinity, 60),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.purple,
            bottom: TabBar(
              labelColor: Colors.purple,
              unselectedLabelColor: Colors.white,
              indicatorWeight: 1,
              indicator: RectangularIndicator(
                color: Colors.white,
              ),
              indicatorColor: Colors.white,
              tabs: [
                Container(margin: EdgeInsets.all(20), child: Text("Friends")),
                Tab(child: Text("Chats"))
              ],
            ),
          ),
        ),
        body: TabBarView(children: [
          FriendList(),
          ChatScreen(),
        ]),
      ));
}

class FriendList extends StatefulWidget {
  const FriendList({Key key}) : super(key: key);

  @override
  _FriendListState createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
  @override
  void initState() {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("Friends")
        .snapshots()
        .listen((event) {
      event.docChanges.forEach((element) {
        if (element.type != null && element.type == DocumentChangeType.added) {
          if (!friends.contains(element.doc.get("id"))) {
            friends.insert(0, element.doc.get("id"));
          }
          if (mounted) {
            setState(() {});
          }
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (friends.isEmpty) {
      return new Container();
    } else {
      return ListView.builder(
          itemCount: friends.length,
          itemBuilder: (_, index) {
            return userCardFromFirebase(friends[index]);
          });
    }
  }

  Widget userCardFromFirebase(String id) {
    return StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection("Users").doc(id).snapshots(),
        builder: (context, streamSnapshot) {
          var user;
          if (streamSnapshot.hasData) {
            user = localUser.User.fromJson(streamSnapshot.data.data());
          } else {
            user = localUser.User(id: "", name: "", profilePic: "");
          }
          return userCard(user, context, false);
        });
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var indexMap = Map<String, int>();
  var latestMessages = [];

  @override
  void initState() {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("Latest Messages")
        .orderBy('time')
        .snapshots()
        .listen((event) {
      event.docChanges.forEach((element) {
        var latestMessage = LatestMessage.fromJson(element.doc.data());
        if (element.type == DocumentChangeType.added) {
          latestMessages.insert(0, latestMessage.userId);
          setState(() {});
          print("size is ${latestMessages.length}");
        } else if (element.type == DocumentChangeType.modified) {
          latestMessages.remove(latestMessage.userId);
          latestMessages.insert(0, latestMessage.userId);
          setState(() {});
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
        itemCount: latestMessages.length,
        itemBuilder: (context, index) {
          return ListTile(
            key: ValueKey(index),
            title: FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection("Users")
                    .doc(latestMessages[index])
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var user = localUser.User.fromJson(snapshot.data.data());
                    return userCard(user, context, false,isLatestFragmentTile:true,friendId: latestMessages[index]);
                  } else {
                    return Container();
                  }
                }),
          );
        },
    onReorder: (oldIndex,newIndex){},);
  }
}

Widget userCard(localUser.User user, BuildContext context, bool addButton,{bool isLatestFragmentTile=false,String friendId}) {
  return GestureDetector(
    onTap: () {
      if (!addButton && user.id != "") {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => ChatActivity(user)));
      }
    },
    child: Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(30, 10, 20, 10),
              height: 60,
              width: 60,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: getImage(user.profilePic),
              ),
            ),
            Column(
              children: [
                Text(
                  user.name,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400, fontSize: 19),
                ),
                Visibility(
                  visible: isLatestFragmentTile,
                    child: FutureBuilder(
                      future: FirebaseFirestore.instance.collection("Users")
                      .doc(FirebaseAuth.instance.currentUser.uid).collection("Messages")
                      .doc(friendId).collection("Messages").orderBy('time',descending: true).limit(1).get(),
                      builder: (context,AsyncSnapshot<QuerySnapshot> snapshot){
                        if(snapshot.hasData){
                          var message;
                          snapshot.data.docs.forEach((element) {
                            message=Message.fromJson(element.data());
                          });
                          return Text(message.message);
                        }else{
                          return Container();
                        }
                      },
                    )),
                Visibility(
                    visible: addButton && !friends.contains(user.id),
                    child: ElevatedButton(
                      onPressed: () {
                        ShowDialog("Adding", context);
                        FirebaseFirestore.instance
                            .collection("Users")
                            .doc(FirebaseAuth.instance.currentUser.uid)
                            .collection("Friends")
                            .add(Friend(id: user.id).toJson())
                            .then((value) {
                          Navigator.pop(context);
                        });
                      },
                      child: Text("Add Friend"),
                      style: ElevatedButton.styleFrom(primary: Colors.purple),
                    ))
              ],
            )
          ],
        ),
        Container(
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
          child: Divider(
            color: Colors.grey.withOpacity(0.2),
            thickness: 2,
          ),
        )
      ],
    ),
  );
}

Widget getImage(String profilePic) {
  if (profilePic == "") {
    return Image.asset("Images/user.png");
  } else {
    return Image.network(profilePic);
  }
}
