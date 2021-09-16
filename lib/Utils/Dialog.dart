

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget LoadingDialog(String title){
  return Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 5.0,
    backgroundColor: Colors.white,
    child: Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(height: 20),
          CircularProgressIndicator(),
          Container(height: 30,),
          Text(title,style: GoogleFonts.goldman(fontSize: 16),),
          Container(height: 20,)
        ],
      ),
    ),
  );
}