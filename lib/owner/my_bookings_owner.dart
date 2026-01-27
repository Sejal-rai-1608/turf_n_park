import 'dart:convert';

import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:turfandpark/pages/booking_details.dart';

import '../helpers/helper_functions.dart';

// import 'pre_login_owner.dart';
class MyBookingsOwner extends StatefulWidget {
  const MyBookingsOwner({Key? key}) : super(key: key);

  @override
  State<MyBookingsOwner> createState() => _MyBookingsOwnerState();
}

class _MyBookingsOwnerState extends State<MyBookingsOwner> {
  bool isLoading = false;
  String type = "turf";
  var bookings = [];
  int currRating = 0;

  final TextEditingController feedbackController = TextEditingController();
  // @override
  // void initState() {
  //   super.initState();
  //   bookings.add({"id": "1", "title": "The Best Title", "desc": "Lorem Ipsum is simply dummy text of the priniting and typesettng industry."});
  //   bookings.add({"id": "2", "title": "The Best Title 1", "desc": "Lorem Ipsum is simply dummy text of the printing and typesetting industry."});
  //   bookings.add({"id": "3", "title": "The Best Title 2", "desc": "Lorem Ipsum is simply dummy text of the printing and typesetting industry."});
  //   bookings.add({"id": "4", "title": "The Best Title 3", "desc": "Lorem Ipsum is simply dummy text of the printing and typesetting industry."});
  //   bookings.add({"id": "5", "title": "The Best Title 3", "desc": "Lorem Ipsum is simply dummy text of the printing and typesetting industry."});
  //   bookings.add({"id": "6", "title": "The Best Title 3", "desc": "Lorem Ipsum is simply dummy text of the printing and typesetting industry."});
  //   bookings.add({"id": "7", "title": "The Best Title 3", "desc": "Lorem Ipsum is simply dummy text of the printing and typesetting industry."});
  //   bookings.add({"id": "8", "title": "The Best Title 3", "desc": "Lorem Ipsum is simply dummy text of the printing and typesetting industry."});
  // }

  @override
  void initState() {
    super.initState();
    getBookings(context);
  }

  getBookings(context) async {
    setState(() {
      isLoading = true;
    });
    var url = Uri.parse(Constants.base_url + 'Owner/my_bookings');
    var response = await http.post(url, body: {
      "userToken": Constants.token,
      "type": "$type",
    });
    var body = jsonDecode(response.body);

    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      var list = body['data'];
      if (list == []) {
        setState(() {
          bookings = [];
        });
      } else {
        setState(() {
          bookings = list;
        });
      }
      print(bookings);
    } else if (response.statusCode == 401) {
      showSnackbar(context, body['message']);
      onLogout(context);
    } else {
      showSnackbar(context, body['message']);
      bookings = [];
      // cart_total = 0;
      setState(() {});
    }
  }

  submitRating(data) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18.0)),
        ),
        builder: (context) {
          double size = MediaQuery.of(context).size.width * .39;

          return StatefulBuilder(builder: (BuildContext context,
              StateSetter setState /*You can rename this!*/) {
            return Container(
                padding: EdgeInsets.all(20),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      Text("Add Review",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      Divider(),
                      Text("Ratings",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.normal)),
                      SizedBox(height: 10),
                      Container(
                          width: 250,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    currRating = 1;
                                    setState(() {});
                                  },
                                  icon: Icon(
                                      currRating >= 1
                                          ? Icons.star
                                          : Icons.star_border,
                                      size: 32,
                                      color: currRating >= 1
                                          ? Colors.yellow
                                          : Colors.grey.shade400)),
                              IconButton(
                                  onPressed: () {
                                    currRating = 2;
                                    setState(() {});
                                  },
                                  icon: Icon(
                                      currRating >= 2
                                          ? Icons.star
                                          : Icons.star_border,
                                      size: 32,
                                      color: currRating >= 2
                                          ? Colors.yellow
                                          : Colors.grey.shade400)),
                              IconButton(
                                  onPressed: () {
                                    currRating = 3;
                                    setState(() {});
                                  },
                                  icon: Icon(
                                      currRating >= 3
                                          ? Icons.star
                                          : Icons.star_border,
                                      size: 32,
                                      color: currRating >= 3
                                          ? Colors.yellow
                                          : Colors.grey.shade400)),
                              IconButton(
                                  onPressed: () {
                                    currRating = 4;
                                    setState(() {});
                                  },
                                  icon: Icon(
                                      currRating >= 4
                                          ? Icons.star
                                          : Icons.star_border,
                                      size: 32,
                                      color: currRating >= 4
                                          ? Colors.yellow
                                          : Colors.grey.shade400)),
                              IconButton(
                                  onPressed: () {
                                    currRating = 5;
                                    setState(() {});
                                  },
                                  icon: Icon(
                                      currRating >= 5
                                          ? Icons.star
                                          : Icons.star_border,
                                      size: 32,
                                      color: currRating >= 5
                                          ? Colors.yellow
                                          : Colors.grey.shade400)),
                            ],
                          )),
                      Divider(),
                      Text("Feedback",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.normal)),
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: TextField(
                          controller: feedbackController,
                          keyboardType: TextInputType.multiline,
                          autofocus: true,
                          decoration: InputDecoration(
                              // prefixIcon: Icon(Icons.call_outlined,color: Colors.green.shade200),
                              // hintText: "Mobile No.",
                              labelText: "Type your feedback here...",
                              labelStyle:
                                  TextStyle(color: Colors.green.shade200)),
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                          width: MediaQuery.of(context).size.width * 88,
                          alignment: Alignment.center,
                          child: GestureDetector(
                              onTap: () {
                                if (currRating == 0) {
                                  showSnackbar(
                                      context, "Please select ratings");
                                  return;
                                }
                                if (feedbackController.text.length <= 3) {
                                  showSnackbar(context,
                                      "Please type atleast 4 characters in feedback.");
                                  return;
                                }
                                Navigator.of(context).pop();
                                submitReview(data);
                                // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>CheckoutCart()));
                              },
                              child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1,
                                          color: Colors.green.shade400),
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Text("Submit",
                                      style: TextStyle(
                                          color: Colors.green.shade400,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)))))
                    ]));
          });
        });
  }

  submitReview(data) async {
    // setState(() {
    //     isLoading = true;
    //   });
    var url = Uri.parse(Constants.base_url + 'Service/add_review');
    var response = await http.post(url, body: {
      "userToken": Constants.token,
      "turf_id": data['parking_id'],
      "rating": currRating.toString(),
      "comment": feedbackController.text,
      "type": data['type']
    });
    var body = jsonDecode(response.body);

    // setState(() {
    //   isLoading = false;
    // });
    if (response.statusCode == 200) {
      currRating = 0;
      feedbackController.text = "";
      showSnackbar(context, body['message']);
    } else if (response.statusCode == 401) {
      showSnackbar(context, body['message']);
      onLogout(context);
    } else {
      showSnackbar(context, body['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            // padding:EdgeInsets.symmetric(horizontal:10),
            color: Colors.white,
            child: Column(
              children: [
                // SizedBox(height: 10,),
                Row(
                    // alignment: Alignment.topRight,
                    // crossAxisAlignment:CrossAxisAlignment.,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          padding: EdgeInsets.only(left: 15, top: 10),
                          child: Text("My Bookings",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24))),

                      Container(
                        padding: EdgeInsets.only(right: 20, top: 10),
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: 34,
                          height: 34,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(17))
                              // shape:BoxShape.circle
                              ),
                          child: IconButton(
                            icon: Icon(Icons.close),
                            iconSize: 18,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // SizedBox(width: 20,),
                    ]),
                SizedBox(
                  height: 10,
                ),
                Text("Select Filter"),
                SizedBox(
                  height: 5,
                ),
                CustomRadioButton(
                  elevation: 0,
                  absoluteZeroSpacing: true,
                  unSelectedColor: Theme.of(context).canvasColor,
                  buttonLables: [
                    'All',
                    'Turf',
                    'Parking',
                  ],
                  buttonValues: [
                    "",
                    "turf",
                    "parking",
                  ],
                  defaultSelected: "",
                  buttonTextStyle: ButtonTextStyle(
                      selectedColor: Colors.white,
                      unSelectedColor: Colors.black,
                      textStyle: TextStyle(fontSize: 16)),
                  radioButtonValue: (value) {
                    type = value.toString();
                    getBookings(context);
                  },
                  selectedColor: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(
                  height: 30,
                ),
                bookings.isEmpty
                    ? Column(
                        children: [
                          SizedBox(
                            height: 30,
                          ),
                          Center(
                            child: Text(
                              "No bookings Found ",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      )
                    : SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Form(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isLoading)
                                  for (var i = 0; i < 4; i++)
                                    Container(
                                      child: Shimmer.fromColors(
                                        baseColor: Colors.grey.shade400,
                                        highlightColor: Colors.grey.shade600,
                                        enabled: true,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20)),
                                            color: Colors.white,
                                          ),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.90,
                                          height: 200,
                                          margin: EdgeInsets.all(10),
                                        ),
                                      ),
                                    ),
                                if (!isLoading)
                                  for (var i = 0; i < bookings.length; i++)
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder: (context) =>
                                                    BookingDetails(
                                                        bookings[i])))
                                            .then((value) => {
                                                  if (value == true)
                                                    {getBookings(context)}
                                                });
                                      },
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          //  Container(width:40,child: Icon(Icons.label_important_outline,color: Colors.blue,)),
                                          Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(20)),
                                                  // boxShadow: [
                                                  //   BoxShadow(
                                                  //     color: Colors.grey.shade400,
                                                  //     blurRadius:
                                                  //         5.0, // soften the shadow
                                                  //     spreadRadius:
                                                  //         2.0, //extend the shadow
                                                  //     offset: Offset(
                                                  //       6.0, // Move to right 10  horizontally
                                                  //       6.0, // Move to bottom 10 Vertically
                                                  //     ),
                                                  //   )
                                                  // ],
                                                  color: Colors.grey.shade200),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.85,
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 10),
                                              padding: EdgeInsets.all(10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  if (bookings[i]
                                                          ['is_cancelled'] ==
                                                      "1")
                                                    Container(
                                                        decoration:
                                                            BoxDecoration(
                                                                // border:Border.all(color: Colors.red.shade400),
                                                                // borderRadius: BorderRadius.all(Radius.circular(8))
                                                                ),
                                                        padding:
                                                            EdgeInsets.all(4),
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Text(
                                                          "Cancelled",
                                                          style: TextStyle(
                                                            color: Colors
                                                                .red.shade400,
                                                          ),
                                                        )),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    // mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      if (bookings[i]
                                                              ['image'] !=
                                                          null)
                                                        Container(
                                                          width: 65,
                                                          height: 65,
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: Colors
                                                                      .grey,
                                                                  image:
                                                                      DecorationImage(
                                                                    image: NetworkImage(
                                                                        bookings[i]
                                                                            [
                                                                            'image']),
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                  // borderRadius: BorderRadius.all(Radius.circular(17)),
                                                                  shape: BoxShape
                                                                      .circle),
                                                        ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          if (bookings[i]
                                                                  ['title'] !=
                                                              null)
                                                            Text(
                                                                bookings[i]
                                                                    ['title'],
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        18)),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          if (bookings[i]
                                                                  ['address'] !=
                                                              null)
                                                            Container(
                                                                width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.85 -
                                                                    98,
                                                                child: Text(
                                                                    bookings[i][
                                                                        'address'],
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .grey))),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 15,
                                                  ),
                                                  Container(
                                                      child: Text(
                                                    "Booked On : " +
                                                        bookings[i]['date']
                                                            .toString(),
                                                  )),
                                                  SizedBox(
                                                    height: 15,
                                                  ),
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width -
                                                            85,
                                                    child: Text(
                                                        "Amount : Rs." +
                                                            bookings[i]
                                                                    ['amount']
                                                                .toString(),
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 15)),
                                                  ),
                                                  SizedBox(
                                                    height: 3,
                                                  ),
                                                  bookings[i]['used'] == true
                                                      ? Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 10,
                                                                  right: 10),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              GestureDetector(
                                                                  onTap: () {
                                                                    submitRating(
                                                                        bookings[
                                                                            i]);
                                                                  },
                                                                  child: Container(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              6),
                                                                      decoration: BoxDecoration(
                                                                          border: Border.all(
                                                                              color: Colors
                                                                                  .red.shade400)),
                                                                      child: Text(
                                                                          "Add Review",
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.normal,
                                                                              fontSize: 13,
                                                                              color: Colors.red.shade400)))),
                                                              Text(
                                                                  "View Details",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .grey
                                                                          .shade700))
                                                            ],
                                                          ),
                                                        )
                                                      : Container(
                                                          alignment: Alignment
                                                              .topRight,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width -
                                                              85,
                                                          child: Text(
                                                              "View Details",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade700)),
                                                        ),
                                                  SizedBox(
                                                    height: 8,
                                                  )
                                                ],
                                              ))
                                        ],
                                      ),
                                    )
                              ],
                            ),
                          ),
                        ),
                      )
              ],
            ) /* add child content here */,
          ),
        ),
      ),
    );
  }
}
