import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:turfandpark/pages/turfList.dart';

import '../helpers/drawer.dart';
import '../helpers/helper_functions.dart';
import '../helpers/selectLocation.dart';
import 'my_cart.dart';
import 'parking_details.dart';

class ParkingList extends StatefulWidget {
  const ParkingList({Key? key}) : super(key: key);

  @override
  State<ParkingList> createState() => _ParkingListState();
}

class _ParkingListState extends State<ParkingList> {
  List parkingList = [];
  bool isLoading = false;
  String filter = "";
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    getTurfs(context);
  }

  getTurfs(context) async {
    setState(() {
      isLoading = true;
    });
    var city = Constants.city_id == "" ? "" : Constants.city_id;
    var url = Uri.parse(Constants.base_url + 'Service/parking_list');
    var response = await http.post(url, body: {
      "city": city,
      "parking_type": filter,
      "search": searchController.text
    });
    var body = jsonDecode(response.body);

    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      var list = body['message'];
      setState(() {
        parkingList = list;
      });
    } else if (response.statusCode == 401) {
      showSnackbar(context, body['message']);
      onLogout(context);
    } else {
      // showSnackbar(context, body['message']);
      parkingList = [];
      setState(() {});
    }
  }

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
    child:Scaffold(
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
                  child: Row(children: [
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
              ]))),
        ])), //Text("Add New Prospect",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 18),),
        actions: [
          Stack(
            children: [
              IconButton(
                  onPressed: () => {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => MyCart(
                                  update: () {
                                    setState(() {});
                                  },
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
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5)),
                // alignment:Alignment.center,
                child: Center(
                  child: TextField(
                    onChanged: (v) => {getTurfs(context)},
                    controller: searchController,
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            /* Clear the search field */
                            searchController.text = "";
                            getTurfs(context);
                          },
                        ),
                        hintText: 'Search',
                        border: InputBorder.none),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Available Parkings",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(18.0))),
                          backgroundColor: Colors.white,
                          context: context,
                          // isScrollControlled: false,
                          builder: (context) {
                            return SingleChildScrollView(
                              child: Wrap(
                                children: [
                                  ListTile(
                                    onTap: () {
                                      filter = "2 Wheeler";
                                      Navigator.of(context).pop();
                                      getTurfs(context);
                                    },
                                    leading: Icon(Icons.pedal_bike),
                                    title: Text('2 Wheeler'),
                                  ),
                                  ListTile(
                                    onTap: () {
                                      filter = "4 Wheeler";
                                      Navigator.of(context).pop();
                                      getTurfs(context);
                                    },
                                    leading: Icon(Icons.car_repair),
                                    title: Text('4 Wheeler'),
                                  ),
                                  ListTile(
                                    onTap: () {
                                      filter = "";
                                      Navigator.of(context).pop();
                                      getTurfs(context);
                                    },
                                    leading: Icon(Icons.close),
                                    title: Text('Clear Filter'),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      icon: Icon(
                        Icons.filter_alt_rounded,
                        size: 32,
                      )),
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
                      height: 200,
                      margin: EdgeInsets.all(10),
                    ),
                  ),
                ),
            if (!isLoading && parkingList.length == 0)
              Container(
                padding: EdgeInsets.only(top: 60),
                alignment: Alignment.center,
                child: Text("No Parkings Found",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              ),
            if (!isLoading)
              for (var i = 0; i < parkingList.length; i++)
                GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              ParkingDetails(parkingList[i])));
                    },
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),

                      height: 180,
                      // width: MediaQuery.of(context).size.width*0.85,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(parkingList[i]['main_image']),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Stack(
                        children: [
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
                                    Colors.black.withOpacity(0.0),
                                    Colors.black.withOpacity(0.2),
                                  ],
                                ),
                                // Colors.black.withOpacity(0.5)
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Row(children: [
                                      Text(" " + parkingList[i]['title'],
                                          overflow: TextOverflow.clip,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            // backgroundColor: Colors.black45
                                          ))
                                    ])
                                  ]),
                                  Text(" " + parkingList[i]['address'],
                                      style: TextStyle(color: Colors.white)),
                                  SizedBox(
                                    height: 55,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(14)),
                                                  color: Colors.white),
                                              alignment: Alignment.center,
                                              child: Text("Book Now",
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                            ),
                                          )),
                                      Container(
                                          width: 100,
                                          child:
                                              parkingList[i]['rating'] != null
                                                  ? Row(
                                                      // mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Icon(
                                                            int.parse(parkingList[i]
                                                                            [
                                                                            'rating']
                                                                        .toString()) >=
                                                                    1
                                                                ? Icons.star
                                                                : Icons
                                                                    .star_border,
                                                            size: 17,
                                                            color: int.parse(parkingList[i]
                                                                            [
                                                                            'rating']
                                                                        .toString()) >=
                                                                    1
                                                                ? Colors.yellow
                                                                : Colors.white),
                                                        Icon(
                                                            int.parse(parkingList[i]
                                                                            [
                                                                            'rating']
                                                                        .toString()) >=
                                                                    2
                                                                ? Icons.star
                                                                : Icons
                                                                    .star_border,
                                                            size: 17,
                                                            color: int.parse(parkingList[i]
                                                                            [
                                                                            'rating']
                                                                        .toString()) >=
                                                                    2
                                                                ? Colors.yellow
                                                                : Colors.white),
                                                        Icon(
                                                            int.parse(parkingList[i]
                                                                            [
                                                                            'rating']
                                                                        .toString()) >=
                                                                    3
                                                                ? Icons.star
                                                                : Icons
                                                                    .star_border,
                                                            size: 17,
                                                            color: int.parse(parkingList[i]
                                                                            [
                                                                            'rating']
                                                                        .toString()) >=
                                                                    3
                                                                ? Colors.yellow
                                                                : Colors.white),
                                                        Icon(
                                                            int.parse(parkingList[i]
                                                                            [
                                                                            'rating']
                                                                        .toString()) >=
                                                                    4
                                                                ? Icons.star
                                                                : Icons
                                                                    .star_border,
                                                            size: 17,
                                                            color: int.parse(parkingList[i]
                                                                            [
                                                                            'rating']
                                                                        .toString()) >=
                                                                    4
                                                                ? Colors.yellow
                                                                : Colors.white),
                                                        Icon(
                                                            int.parse(parkingList[i]
                                                                            [
                                                                            'rating']
                                                                        .toString()) >=
                                                                    5
                                                                ? Icons.star
                                                                : Icons
                                                                    .star_border,
                                                            size: 17,
                                                            color: int.parse(parkingList[i]
                                                                            [
                                                                            'rating']
                                                                        .toString()) >=
                                                                    5
                                                                ? Colors.yellow
                                                                : Colors.white),
                                                      ],
                                                    )
                                                  : SizedBox.shrink())
                                    ],
                                  )
                                ]),
                          ),
                        ],
                      ),
                    )),
            //   SingleChildScrollView(
            //   child: Container(
            //     padding: EdgeInsets.symmetric(horizontal: 10),
            //     child: Column(
            //       children: [
            //         SizedBox(height: 10,),
            //         for(var i=0;i<10;i++)
            //         GestureDetector(
            //           child: Container(
            //             margin:EdgeInsets.only(bottom:20),
            //             height: 180,
            //             // width: MediaQuery.of(context).size.width*0.85,
            //             decoration: BoxDecoration(
            //               image: DecorationImage(
            //                 image: AssetImage("assets/turf.jpg"),
            //                 fit: BoxFit.cover,
            //               ),
            //                borderRadius: BorderRadius.all(Radius.circular(20)),
            //                 boxShadow: [
            //                   BoxShadow(
            //                     color: Colors.grey,
            //                     blurRadius: 5.0, // soften the shadow
            //                     spreadRadius: 2.0, //extend the shadow
            //                     offset: Offset(
            //                       6.0, // Move to right 10  horizontally
            //                       6.0, // Move to bottom 10 Vertically
            //                     ),
            //                   )
            //                 ]
            //             ),
            //             child: Container(
            //               // color: Colors.black,
            //               alignment: Alignment.center,
            //               child: SizedBox(
            //                 width:90,
            //                 height:35,
            //                 child: Container(
            //                   // width: ,
            //                   // color: Colors.black,
            //                   decoration: BoxDecoration(
            //                     borderRadius: BorderRadius.all(Radius.circular(8)),
            //                     color: Colors.black
            //                   ),
            //                   alignment: Alignment.center,
            //                   child: Text("Book Turf",
            //                   style: TextStyle(
            //                     fontSize: 17,
            //                     color: Colors.white,
            //                     fontWeight: FontWeight.w600
            //                     )
            //                   ),
            //                 ),
            //               )
            //             ),
            //           ),
            //         ),

            //       ],
            //       ) /* add child content here */,
            //   ),
            // ),
          ]),
        ),
      ),),
    );
  }
// Widget create
}
