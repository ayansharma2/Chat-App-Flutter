import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chat_app/Models/User.dart' as localUser;
import 'package:tab_indicator_styler/tab_indicator_styler.dart';
class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

final friendNameController = TextEditingController();
TabController _tabController;
class _HomeState extends State<Home> with TickerProviderStateMixin{
  bool isSearchClicked=false;
  @override
  void initState() {
    _tabController = new TabController(vsync: this, length: 3);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.purple,
        title: Text("You Chat", style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),),
      actions: [
        GestureDetector(
          onTap: (){ isSearchClicked = !isSearchClicked;
          setState(() {});
          },
          child: Container(
            margin: EdgeInsets.only(right: 10),
            child: Icon( (isSearchClicked) ? Icons.arrow_back_ios_new : Icons.search),
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
     if(isSearchClicked){
     return topTextField(context, friendNameController);
    }else{
      return Expanded(child: tabLayout());
    }
  }
}




Widget topTextField(BuildContext context,
    TextEditingController friendNameController) {
  return Container(
    decoration: BoxDecoration(
        color: Colors.purple
    ),
    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
    child: TextFormField(
      controller: friendNameController,
      decoration: InputDecoration(
          labelText: "Search your Friend",
          labelStyle: TextStyle(color: Colors.purple),
          fillColor: Colors.white,
          filled: true,
          border: InputBorder.none
      ),
      cursorColor: Colors.purple,
      style: TextStyle(color: Colors.black),
    ),
  );
}


Widget tabLayout() {

  if (friendNameController.text.isEmpty) {
    return DefaultTabController(
        length: 2, child: Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity,60),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.purple,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.purple,
            unselectedLabelColor: Colors.white,
            indicatorWeight: 1,
            indicator: RectangularIndicator(
              color: Colors.white,
            ),
            indicatorColor: Colors.white,
            tabs: [
              Container(margin:EdgeInsets.all(20),child: Text("Friends")),
              Tab(child: Text("Chats"))
            ],
          ),
        ),
      ),
      body: TabBarView(children: [
        FriendList(),
        Container(),
      ]),
    ));
  }else{
  return new Scaffold();
  }

}


class FriendList extends StatefulWidget {
  const FriendList({Key key}) : super(key: key);

  @override
  _FriendListState createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {



  var users= [];
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("Users").snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot){
        if(streamSnapshot.hasData){
          return ListView.builder(
              itemCount: streamSnapshot.data.docs.length,
              itemBuilder: (_,index){
                var user=localUser.User.fromJson(streamSnapshot.data.docs[index].data());
                return Column(
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
                            child: Image.network(user.profilePic),
                          ),
                        ),
                        Text(user.name,style: GoogleFonts.inter(fontWeight: FontWeight.w400,fontSize: 19),)
                      ],
                    ),
                    Container(width: double.infinity,margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
                    child: Divider(color: Colors.grey.withOpacity(0.2),thickness: 2,),)
                  ],
                );
              });
        }else{
          return Container();
        }
        });
  }
}





