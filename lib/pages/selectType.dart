import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:turfandpark/helpers/helper_functions.dart';
import 'parkingList.dart';
import 'turfList.dart';

class SelectType extends StatefulWidget {
  const SelectType({Key? key}) : super(key: key);

  @override
  State<SelectType> createState() => _SelectTypeState();
}

class _SelectTypeState extends State<SelectType> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 2,
                      offset: Offset(2, 0),
                    ),
                  ],
                  color: Colors.black,
                  // borderRadius: BorderRadius.vertical(
                  //   top: Radius.circular(25),
                  // ),
                  image: DecorationImage(
                    // opacity: 0.5,
                    colorFilter: new ColorFilter.mode(
                        Colors.black.withOpacity(0.2), BlendMode.dstATop),
                    image: AssetImage(
                        "assets/henrique-macedo-8RzMsxk3wgg-unsplash.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),
                      ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.asset(
                            "assets/logo.png",
                          )),
                      SizedBox(
                        height: 35,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Hi, " + Constants.name,
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "What are you looking for today?",
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )),
                      SizedBox(
                        height: 25,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => TurfList()));
                        },
                        child: Container(
                          height: 180,
                          width: MediaQuery.of(context).size.width * 0.85,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("assets/turf.jpg"),
                                fit: BoxFit.cover,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 5.0, // soften the shadow
                                  spreadRadius: 2.0, //extend the shadow
                                  offset: Offset(
                                    6.0, // Move to right 10  horizontally
                                    6.0, // Move to bottom 10 Vertically
                                  ),
                                )
                              ]),
                          child: Container(
                              // color: Colors.black,
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: 90,
                                height: 35,
                                child: Container(
                                  // width: ,
                                  // color: Colors.black,
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                      color: Colors.black),
                                  alignment: Alignment.center,
                                  child: Text("Book Turf",
                                      style: TextStyle(
                                          fontSize: 17,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600)),
                                ),
                              )),
                        ),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => ParkingList()));
                        },
                        child: Container(
                          height: 180,
                          width: MediaQuery.of(context).size.width * 0.85,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("assets/parking.jpg"),
                                fit: BoxFit.cover,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 5.0, // soften the shadow
                                  spreadRadius: 2.0, //extend the shadow
                                  offset: Offset(
                                    6.0, // Move to right 10  horizontally
                                    6.0, // Move to bottom 10 Vertically
                                  ),
                                )
                              ]),
                          child: Container(
                              // color: Colors.black,
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: 130,
                                height: 35,
                                child: Container(
                                  // width: ,
                                  // color: Colors.black,
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                      color: Colors.black),
                                  alignment: Alignment.center,
                                  child: Text("Book Parking",
                                      style: TextStyle(
                                          fontSize: 17,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600)),
                                ),
                              )),
                        ),
                      )
                    ],
                  ),
                ) /* add child content here */,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
