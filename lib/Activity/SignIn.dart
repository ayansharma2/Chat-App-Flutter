import 'package:chat_app/Activity/Home.dart';
import 'package:chat_app/Models/User.dart' as localUser;
import 'package:chat_app/Utils/Dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {



  var controller = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Column(
            children: [
              Expanded(
                  child: PageView(
                controller: controller,
                children: [pageViewItemOne(context), pageViewItemTwo(context)],
              )),
              SmoothPageIndicator(
                controller: controller,
                count: 2,
                effect:
                    ScrollingDotsEffect(dotWidth: 12, radius: 6, dotHeight: 12),
              )
            ],
          )),
          GestureDetector(
            onTap: () async {
              ShowDialog("Logging In", context);
              signWithGoogle();

            },
            child: Card(
              elevation: 15,
              color: Colors.purple,
              margin: EdgeInsets.fromLTRB(25, 50, 25, 80),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 15, 0, 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("Images/search.png", width: 23, height: 23),
                    Container(
                      width: 20,
                    ),
                    Text(
                      "Continue with Google",
                      style: GoogleFonts.montserrat(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    Container(
                      width: 15,
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget pageViewItemOne(BuildContext context) {
    return new Column(
      children: [
        Container(
          height: 50,
        ),
        Image.asset(
          'Images/chat.png',
        ),
        Container(
          height: 30,
        ),
        Text(
          "Chat With your friends",
          style: GoogleFonts.heebo(color: Colors.blue),
        ),
        Container(
          height: 30,
        )
      ],
    );
  }

  Widget pageViewItemTwo(BuildContext context) {
    return new Column(
      children: [
        Container(
          height: 50,
        ),
        Container(
          height: 250,
          child: Image.asset(
            'Images/security.jpg',
          ),
        ),
        Container(
          height: 30,
        ),
        Text(
          "Secure AF",
          style: GoogleFonts.heebo(color: Colors.black),
        ),
        Container(
          height: 30,
        )
      ],
    );
  }

  void signWithGoogle() async {
    final GoogleSignInAccount googleUser=await GoogleSignIn().signIn();
    if(googleUser == null){
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(createSnackBar("Select a valid Google account"));
    }
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await FirebaseAuth.instance.signInWithCredential(credential)
        .then((value){
      if(value.additionalUserInfo.isNewUser){
        var user = new localUser.User(id: value.user.uid, name: value.user.displayName, profilePic: value.user.photoURL) ;
        FirebaseFirestore.instance.collection("Users")
            .doc(user.id)
            .set(user.toJson())
            .whenComplete((){
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Home()),(r)=>false);
        })
            .onError((error, stackTrace){
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(createSnackBar("Error logging in"));
        });
      }else{
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Home()),(r)=>false);
      }
    })
        .catchError((onError){
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(createSnackBar("Error logging in"));
    });
  }



}

SnackBar createSnackBar(String title){
  return SnackBar(content: Text(title,style: TextStyle(color: Colors.white),),
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.purple,);
}

void ShowDialog(String title,BuildContext context){
  showDialog(barrierColor: Colors.grey.withOpacity(0.5),barrierDismissible: false,context: context, builder: (context){
    return WillPopScope(
      onWillPop: () async=>false,
      child: LoadingDialog(title),
    );
  });
}