import 'dart:convert';

import 'package:flutter/material.dart' hide CarouselController;
import 'package:carousel_slider/carousel_slider.dart';

import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:zoom_pinch_overlay/zoom_pinch_overlay.dart';

import '../helpers/helper_functions.dart';

class TurfSchedule extends StatefulWidget {
  Map turfData;
  TurfSchedule(this.turfData);

  @override
  State<TurfSchedule> createState() => _TurfScheduleState(this.turfData);
}

class _TurfScheduleState extends State<TurfSchedule> {
  _TurfScheduleState(this.turfData);
  int selectedDayIndex = 0;
  Map turfData;
  Map turfDetails = {};
  List slotList = [
    // {"time":"7 AM - 8 AM","price":1000},
    // {"time":"8 AM - 9 AM","price":1000},
    // {"time":"9 AM - 10 AM","price":1000},
    // {"time":"10 AM - 11 AM","price":1000},
  ];
  bool isLoading = false;
  bool isLoadingSlot = false;
  List<String> listImages = [];
  @override
  void initState() {
    super.initState();
    getTurfDetails(context);
    listImages = [];
    var temp = widget.turfData['slider_images'].toString().split(',');
    for (var i = 0; i < temp.length; i++) {
      listImages.add("https://turfnpark.com/turf_images/${temp[i]}");
    }
    listImages.add(widget.turfData['main_image']);
  }

  getTurfDetails(context) async {
    if (mounted)
      setState(() {
        isLoading = true;
      });
    var url = Uri.parse(Constants.base_url + 'Service/turf_details');
    var response = await http.post(url, body: {"turf_id": turfData['id']});
    var body = jsonDecode(response.body);
    //
    if (mounted)
      setState(() {
        isLoading = false;
      });
    if (response.statusCode == 200) {
      var list = body['message'];
      if (mounted)
        setState(() {
          turfDetails = list;
        });
      if (turfDetails["dates"].length > 0) {
        if (turfDetails["dates"][0] != null &&
            turfDetails["dates"][0]["full_date"] != null) {
          getTurfSlots(context, turfDetails["dates"][0]["full_date"]);
        }
      }
    } else {
      showSnackbar(context, body['message']);
      turfDetails = {};
      setState(() {});
    }
  }

  getTurfSlots(context, date) async {
    setState(() {
      isLoadingSlot = true;
    });
    var url = Uri.parse(Constants.base_url + 'Service/get_turf_slots');
    var response = await http.post(url, body: {
      "userToken": Constants.token,
      "turf_id": turfData['id'],
      "date": date
    });
    var body = jsonDecode(response.body);

    if (mounted)
      setState(() {
        isLoadingSlot = false;
      });
    if (response.statusCode == 200) {
      var list = body['message'];
      if (mounted)
        setState(() {
          slotList = list;
        });
    } else {
      showSnackbar(context, body['message']);
      slotList = [];
      setState(() {});
    }
  }

  addToCart(context, date, start, end, price, j) async {
    setState(() {
      isLoadingSlot = true;
    });
    var url = Uri.parse(Constants.base_url + 'Service/add_to_cart');
    var response = await http.post(url, body: {
      "userToken": Constants.token,
      "turf_id": turfData['id'],
      "date": date,
      "start_time": start,
      "end_time": end,
      "price": price
    });
    var body = jsonDecode(response.body);
    //
    setState(() {
      isLoadingSlot = false;
    });
    if (response.statusCode == 200) {
      showSnackbar(context, body['message']);
      slotList[j]['is_in_my_cart'] = true;
      //  var list = body['message'];
      setState(() {
        // slotList= list;
      });
    } else {
      showSnackbar(context, body['message']);
      // slotList=[];
      // setState(() {

      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(children: [
            Material(
              child: Container(
                // margin:EdgeInsets.symmetric(horizontal:10,vertical:10 ),
                // padding: EdgeInsets.symmetric(horizontal:10,vertical:10 ),
                height: MediaQuery.of(context).size.height * 0.4,
                width: double.infinity,
                child: CarouselSlider(
                    options: CarouselOptions(
                      scrollPhysics: NeverScrollableScrollPhysics(),
                      autoPlay: true,
                    ),
                    items: listImages.map((i) {
                      return Builder(builder: (BuildContext context) {
                        return InkWell(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ZoomOverlay(
                                        twoTouchOnly: true,
                                        child: Container(
                                          color: Colors.white,
                                          child: FancyShimmerImage(
                                            //  height: 40.h,
                                            imageUrl: i,
                                            errorWidget: Icon(Icons.image),
                                            boxFit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "  Use Two Fingers to zoom the image.  ",
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text("Close"))
                                    ],
                                  );
                                });
                          },
                          child: ZoomOverlay(
                            twoTouchOnly: true,
                            child: Container(
                              color: Colors.white,
                              child: FancyShimmerImage(
                                height: 200,
                                errorWidget: Image.asset(
                                  "assets/logo.png",
                                  fit: BoxFit.cover,
                                ),
                                imageUrl: i,
                                boxFit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      });
                    }).toList()),

                // width: MediaQuery.of(context).size.width*0.85,
                // decoration: BoxDecoration(
                //   image: DecorationImage(
                //     image: NetworkImage(turfData['main_image']),
                //     fit: BoxFit.cover,
                //   ),
                // ),
              ),
            ),
            Positioned(
                top: 10,
                left: 10,
                child: Container(
                    height: 32,
                    decoration: BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, size: 18),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ))),
            Positioned(
              top: 230,
              height: MediaQuery.of(context).size.height - 230,
              child: Container(
                  padding: EdgeInsets.all(20),
                  // alignment: Alignment.bottomCenter,
                  height: MediaQuery.of(context).size.width - 230,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                      color: Colors.white),
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                        // mainAxisAlignment:MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              // crossAxisAlignment: ,
                              children: [
                                Text(turfData['turf_name'],
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                                Text(
                                    "Rs." +
                                        (int.parse(turfData['hourly_rent']))
                                            .toString(),
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                              ]),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            turfData['address'],
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Schedule",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                              height: 80,
                              width: MediaQuery.of(context).size.width * 0.90,
                              child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      if (isLoading)
                                        for (var i = 0; i <= 6; i++)
                                          Container(
                                            padding: EdgeInsets.all(5),
                                            child: Shimmer.fromColors(
                                              baseColor: Colors.grey.shade200,
                                              highlightColor:
                                                  Colors.grey.shade400,
                                              enabled: true,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8)),
                                                  color: Colors.white,
                                                ),
                                                // width: MediaQuery.of(context).size.width*0.90,
                                                height: 75,
                                                width: 50,
                                              ),
                                            ),
                                          ),
                                      if (!isLoading)
                                        for (var i = 0;
                                            i < turfDetails['dates'].length;
                                            i++)
                                          GestureDetector(
                                            onTap: () {
                                              selectedDayIndex = i;
                                              getTurfSlots(
                                                  context,
                                                  turfDetails['dates'][i]
                                                      ['full_date']);
                                              // setState(() {

                                              // });
                                            },
                                            child: Container(
                                                width: 50,
                                                margin: EdgeInsets.all(4),
                                                padding: EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8)),
                                                  // border: Border.all(color:Colors.grey.shade300,width: 1.0),
                                                  color: selectedDayIndex == i
                                                      ? Colors.red.shade400
                                                      : Colors.grey.shade100,
                                                ),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                        turfDetails['dates'][i]
                                                            ['month'],
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 14,
                                                            color: selectedDayIndex ==
                                                                    i
                                                                ? Colors.white
                                                                : Colors
                                                                    .black)),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      turfDetails['dates'][i]
                                                          ['date'],
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18,
                                                          color:
                                                              selectedDayIndex ==
                                                                      i
                                                                  ? Colors.white
                                                                  : Colors.red
                                                                      .shade400),
                                                    ),
                                                  ],
                                                )),
                                          ),
                                    ],
                                  ))),
                          if (isLoading || isLoadingSlot)
                            for (var j = 0; j < slotList.length; j++)
                              Container(
                                padding: EdgeInsets.all(5),
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey.shade200,
                                  highlightColor: Colors.grey.shade400,
                                  enabled: true,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                      color: Colors.white,
                                    ),
                                    // width: MediaQuery.of(context).size.width*0.90,
                                    height: 50,
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                  ),
                                ),
                              ),
                          if (!isLoadingSlot)
                            for (var j = 0; j < slotList.length; j++)
                              GestureDetector(
                                onTap: () {
                                  // if (slotList[j]['is_booked']) {
                                  //   showSnackbar(context,
                                  //       "This Slot is Already Booked.");
                                  // } else if (slotList[j]['is_in_my_cart']) {
                                  //   showSnackbar(context,
                                  //       "This Slot is Already in your cart.");
                                  // } else {
                                  //   addToCart(
                                  //       context,
                                  //       turfDetails["dates"][selectedDayIndex]
                                  //           ['full_date'],
                                  //       slotList[j]['start'],
                                  //       slotList[j]['end'],
                                  //       slotList[j]['rent'],
                                  //       j);
                                  // }
                                },
                                child: Container(
                                    height: 60,
                                    margin: EdgeInsets.all(4),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                      border: slotList[j]['is_booked'] == true
                                          ? Border.all(
                                              color: Colors.red.shade400,
                                              width: 1.0)
                                          : (slotList[j]['is_in_my_cart'] ==
                                                  true
                                              ? Border.all(
                                                  color: Colors.grey.shade400,
                                                  width: 1.0)
                                              : Border.all(
                                                  color: Colors.grey.shade100,
                                                  width: 1.0)),
                                      color:
                                          slotList[j]['is_in_my_cart'] == true
                                              ? Colors.green.shade400
                                              : Colors.grey.shade100,
                                    ),
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          slotList[j]['label'],
                                          style: TextStyle(
                                              color: slotList[j]
                                                          ['is_in_my_cart'] ==
                                                      true
                                                  ? Colors.white
                                                  : Colors.black),
                                        ),
                                        Container(
                                            padding: EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8)),
                                              border: slotList[j]
                                                          ['is_in_my_cart'] ==
                                                      true
                                                  ? Border.all(
                                                      color: Colors.white,
                                                      width: 1.0)
                                                  : Border.all(
                                                      color:
                                                          Colors.red.shade400,
                                                      width: 1.0),
                                              // color: Colors.grey.shade100,
                                            ),
                                            child:
                                                slotList[j]['is_booked'] == true
                                                    ? Text(
                                                        "Booked.",
                                                        style: TextStyle(
                                                            color: Colors
                                                                .red.shade400),
                                                      )
                                                    : Text(
                                                        "Available - " +
                                                            slotList[j]['rent']
                                                                .toString(),
                                                        style: TextStyle(
                                                            color: slotList[j][
                                                                        'is_in_my_cart'] ==
                                                                    true
                                                                ? Colors.white
                                                                : Colors.red
                                                                    .shade400),
                                                      )),
                                      ],
                                    )),
                              ),
                          SizedBox(
                            height: 50,
                          )
                        ]),
                  )),
            ),
          ]),
        ),
      ),
    );
  }
// Widget create
}
