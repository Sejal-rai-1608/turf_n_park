import 'dart:convert';
import 'dart:io';

import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:turfandpark/helpers/utils.dart';
import 'package:turfandpark/pages/my_cart.dart';

import '../helpers/drawer.dart';
import '../helpers/helper_functions.dart';
import '../helpers/selectLocation.dart';
import 'game_filter.dart';
import 'turf_details.dart';

final CountProviderCart c = Get.put(CountProviderCart());

class TurfList extends StatefulWidget {
  static const String id = 'TurfList_screen';
  const TurfList({Key? key}) : super(key: key);

  @override
  State<TurfList> createState() => _TurfListState();
}

class _TurfListState extends State<TurfList> {
  List turfList = [];
  bool isLoading = false;
  String games = "";
  String search = "";

  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    getTurfs(context);
    c.getCartCount(context);
  }

  getTurfs(context) async {
    setState(() {
      isLoading = true;
    });
    var city = Constants.city_id == "" ? "" : Constants.city_id;
    var lat = Constants.lat == "" ? "" : Constants.lat;
    var long = Constants.long == "" ? "" : Constants.long;
    var url = Uri.parse(Constants.base_url + 'Service/turf_list');
    var response = await http.post(url, body: {
      "city": city,
      "games": games,
      "lat": lat,
      "long": long,
      "search": search
    });

    var body = jsonDecode(response.body);

    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      var list = body['message'];
      setState(() {
        turfList = list;
      });
    } else if (response.statusCode == 401) {
      showSnackbar(context, body['message']);
      onLogout(context);
    } else {
      // showSnackbar(context, body['message']);
      turfList = [];
      setState(() {});
    }
  }

  update() {
    setState(() {});
  }

  // function
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Get.dialog(
          AlertDialog(
            title: Text("Are you sure you want to exit?"),
            actions: [
              ElevatedButton(
                child: Text("Yes"),
                onPressed: () {
                  exit(0);
                },
              ),
              ElevatedButton(
                child: Text("No"),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          ),
        ).then((value) => {
              if (value == true) {Navigator.of(context).pop(true)}
            });
        return Future.value(false);
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          drawer: AppDrawer(),
          appBar: AppBar(
            backgroundColor: Colors.green.shade600,
            // toolbarHeight: 100,
            iconTheme: IconThemeData(color: Colors.white),
            elevation: 0.0,
            title: Container(
                child: Column(children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (context) => SelectLocation()))
                      .then((value) => {
                            if (value == true)
                              {
                                setState(() {}),
                                getTurfs(context)
                                //  setState((){});
                              }
                          });
                },
                child: Container(
                    child: Row(
                  children: [
                    Text(
                      Constants.fullLocation.length > 0
                          ? Constants.fullLocation
                          : "Select Location",
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                    Icon(Icons.keyboard_arrow_down)
                  ],
                )),
              )
            ])),
            actions: [
              // IconButton(
              //     onPressed: () => {
              //           Navigator.of(context).push(MaterialPageRoute(
              //               builder: (context) => NotificationsList()))
              //         },
              //     icon: Icon(Icons.notifications)),
              Stack(
                children: [
                  IconButton(
                      onPressed: () => {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => MyCart(
                                      update: update,
                                    )))
                          },
                      icon: Icon(Icons.shopping_cart_rounded)),
                  Positioned(
                    right: 5,
                    child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Obx(
                            () => Text(
                              c.count.value.toString(),
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )),
                  ),
                ],
              ),
              SizedBox(
                width: 10,
              )
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(children: [
                Container(
                  padding: EdgeInsets.only(left: 18, right: 18, bottom: 10),
                  color: Colors.green.shade600,
                  child: Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5)),
                    // alignment:Alignment.center,
                    child: Center(
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                            fillColor: Colors.white,
                            prefixIcon: Icon(Icons.search),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                /* Clear the search field */
                                search = "";
                                searchController.text = "";
                                getTurfs(context);
                              },
                            ),
                            hintText: 'Search',
                            border: InputBorder.none),
                        onChanged: (v) => {},
                      ),
                    ),
                  ),
                ),
                // if (isLoading || turfList.length > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Available Turfs",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      Spacer(),
                      if (games.length == 0)
                        IconButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) =>
                                          GameFilter(this.games)))
                                  .then((value) => {
                                        if (value.length > 0)
                                          {
                                            games = value,
                                            setState(() {}),
                                            getTurfs(context)
                                            //  setState((){});
                                          }
                                        else
                                          {games = "", getTurfs(context)}
                                      });
                            },
                            icon: Icon(
                              Icons.filter_alt_rounded,
                              size: 24,
                            )),

                      if (games.length > 0)
                        TextButton(
                          onPressed: () {
                            games = "";
                            setState(() {});
                            getTurfs(context);
                          },
                          child: Row(
                            children: [
                              Text(
                                "Clear Filter ",
                              ),
                              Icon(
                                Icons.clear,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      // IconButton(onPressed: (){}, icon:Icon(Icons.sort))
                    ],
                  ),
                ),
                if (isLoading)
                  for (var d = 0; d <= 5; d++)
                    Container(
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey.shade400,
                        highlightColor: Colors.grey.shade600,
                        enabled: true,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            color: Colors.white,
                          ),
                          // width: MediaQuery.of(context).size.width*0.90,
                          height: 200,
                          margin: EdgeInsets.all(10),
                          // child: Container(
                          //   alignment:Alignment.bottomLeft,
                          //   decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.all(Radius.circular(8)),
                          //     color: Colors.white,
                          //   ),
                          //   // width: MediaQuery.of(context).size.width*0.90,
                          //   height: 50,
                          //   margin: EdgeInsets.all(10),
                          //   // child: ,

                          // ),
                        ),
                      ),
                    ),

                // isLoading ? SizedBox(
                //   width: 200.0,
                //   height: 100.0,
                //   child: Shimmer.fromColors(
                //     baseColor: Colors.red,
                //     highlightColor: Colors.yellow,
                //     child: Text(
                //       'Shimmer',
                //
                //       style: TextStyle(
                //         fontSize: 40.0,
                //         fontWeight:
                //         FontWeight.bold,
                //       ),
                //     ),
                //   ),
                // ): SizedBox(height:2),
                if (!isLoading && turfList.length == 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/conifer-1049.png",
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 20),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Text("No Turfs Found",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 22)),
                          ],
                        ),
                      ),
                    ],
                  ),
                if (!isLoading)
                  for (var i = 0; i < turfList.length; i++)
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                TurfDetails(turfList[i], update)));
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        height: 220,
                        // width: MediaQuery.of(context).size.width*0.85,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Stack(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: FancyShimmerImage(
                              imageUrl: turfList[i]['main_image'],
                              boxFit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.7),
                                    Colors.black.withOpacity(0.5),
                                    Colors.black.withOpacity(0.3),
                                    Colors.black.withOpacity(0.0),
                                    Colors.black.withOpacity(0.1),
                                    Colors.black.withOpacity(0.3),
                                  ],
                                ),
                                // Colors.black.withOpacity(0.5)
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(turfList[i]['turf_name'],
                                    overflow: TextOverflow.clip,
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      // backgroundColor: Colors.black45
                                    )),
                                Text(turfList[i]['address'],
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                    padding: EdgeInsets.all(5),
                                    alignment: Alignment.bottomLeft,
                                    child: SizedBox(
                                      width: 95,
                                      height: 40,
                                      child: Container(
                                        // width: ,
                                        // color: Colors.black,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20)),
                                            color: Colors.white),
                                        alignment: Alignment.center,
                                        child: Text("Book Now",
                                            style: TextStyle(
                                                fontSize: 17,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                    )),
                              ],
                            ),
                          ),
                          Positioned(
                            right: 20,
                            bottom: 20,
                            child: Container(
                              width: 100,
                              child: turfList[i]['rating'] != null
                                  ? Row(
                                      // mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                            int.parse(turfList[i]['rating']
                                                        .toString()) >=
                                                    1
                                                ? Icons.star
                                                : Icons.star_border,
                                            size: 17,
                                            color: int.parse(turfList[i]
                                                            ['rating']
                                                        .toString()) >=
                                                    1
                                                ? Colors.yellow
                                                : Colors.white),
                                        Icon(
                                            int.parse(turfList[i]['rating']
                                                        .toString()) >=
                                                    2
                                                ? Icons.star
                                                : Icons.star_border,
                                            size: 17,
                                            color: int.parse(turfList[i]
                                                            ['rating']
                                                        .toString()) >=
                                                    2
                                                ? Colors.yellow
                                                : Colors.white),
                                        Icon(
                                            int.parse(turfList[i]['rating']
                                                        .toString()) >=
                                                    3
                                                ? Icons.star
                                                : Icons.star_border,
                                            size: 17,
                                            color: int.parse(turfList[i]
                                                            ['rating']
                                                        .toString()) >=
                                                    3
                                                ? Colors.yellow
                                                : Colors.white),
                                        Icon(
                                            int.parse(turfList[i]['rating']
                                                        .toString()) >=
                                                    4
                                                ? Icons.star
                                                : Icons.star_border,
                                            size: 17,
                                            color: int.parse(turfList[i]
                                                            ['rating']
                                                        .toString()) >=
                                                    4
                                                ? Colors.yellow
                                                : Colors.white),
                                        Icon(
                                            int.parse(turfList[i]['rating']
                                                        .toString()) >=
                                                    5
                                                ? Icons.star
                                                : Icons.star_border,
                                            size: 17,
                                            color: int.parse(turfList[i]
                                                            ['rating']
                                                        .toString()) >=
                                                    5
                                                ? Colors.yellow
                                                : Colors.white),
                                      ],
                                    )
                                  : Row(
                                      // mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(Icons.star_border,
                                            size: 17, color: Colors.white),
                                        Icon(Icons.star_border,
                                            size: 17, color: Colors.white),
                                        Icon(Icons.star_border,
                                            size: 17, color: Colors.white),
                                        Icon(Icons.star_border,
                                            size: 17, color: Colors.white),
                                        Icon(Icons.star_border,
                                            size: 17, color: Colors.white),
                                      ],
                                    ),
                            ),
                          ),
                        ]),
                      ),
                    ),
              ]),
            ),
          )),
    );
  }
// Widget create
}
