import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

import '../helpers/helper_functions.dart';
import 'booking_details.dart';

// import 'pre_login_owner.dart';
class MyBookings extends StatefulWidget {
  const MyBookings({Key? key}) : super(key: key);

  @override
  State<MyBookings> createState() => _MyBookingsState();
}

class _MyBookingsState extends State<MyBookings> {
  bool isLoading = false;
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
    var url = Uri.parse(Constants.base_url + 'Service/mybookings');
    var response = await http.post(url, body: {"userToken": Constants.token});
    var body = jsonDecode(response.body);
    print(body.toString());
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      var list = body['message'];
      setState(() {
        bookings = list;
      });
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
                                  Get.snackbar("Validate Error",
                                      "Please type At-least 4 characters in feedback.",
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white);
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
    print(body.toString());
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
    return SafeArea(
      top: false,
      child: SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.green.shade500,
            elevation: 0,
            centerTitle: true,
            title: Text(
              "My Bookings",
              style: TextStyle(color: Colors.white),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Container(
              // padding:EdgeInsets.symmetric(horizontal:10),
              color: Colors.white,
              child: Column(
                children: [
                  // SizedBox(height: 10,),
                  // Row(
                  //     // alignment: Alignment.topRight,
                  //     // crossAxisAlignment:CrossAxisAlignment.,
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  //       Container(
                  //           padding: EdgeInsets.only(left: 15, top: 10),
                  //           child: Text("My Bookings",
                  //               style: TextStyle(
                  //                   color: Colors.black,
                  //                   fontWeight: FontWeight.bold,
                  //                   fontSize: 24))),
                  //       Container(
                  //         padding: EdgeInsets.only(right: 20, top: 10),
                  //         alignment: Alignment.centerRight,
                  //         child: Container(
                  //           width: 34,
                  //           height: 34,
                  //           alignment: Alignment.center,
                  //           decoration: BoxDecoration(
                  //               color: Colors.black,
                  //               borderRadius:
                  //                   BorderRadius.all(Radius.circular(17))
                  //               // shape:BoxShape.circle
                  //               ),
                  //           child: IconButton(
                  //             icon: Icon(Icons.close),
                  //             iconSize: 18,
                  //             onPressed: () {
                  //               Navigator.of(context).pop();
                  //             },
                  //             color: Colors.white,
                  //           ),
                  //         ),
                  //       ),
                  //       // SizedBox(width: 20,),
                  //     ]),
                  SizedBox(
                    height: 30,
                  ),
                  SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Form(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isLoading)
                              for (var i = 0; i < 8; i++)
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
                                      width: MediaQuery.of(context).size.width *
                                          0.90,
                                      height: 200,
                                      margin: EdgeInsets.all(10),
                                    ),
                                  ),
                                ),
                            if (!isLoading)
                              if (bookings.length == 0)
                                Padding(
                                  padding: EdgeInsets.only(top: Get.height / 3),
                                  child: Container(
                                      alignment: Alignment.center,
                                      child: Text("No Bookings Found",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                          ))),
                                ),
                            for (var i = 0; i < bookings.length; i++)
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) =>
                                              BookingDetails(bookings[i])))
                                      .then((value) => {
                                            if (value == true)
                                              {getBookings(context)}
                                          });
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border:
                                        Border.all(color: Colors.grey.shade200),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // TOP ROW (Image + Title + Cancel Chip)
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 60,
                                            width: 60,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.grey.shade200,
                                                  width: 2),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                    bookings[i]['image']),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  bookings[i]['title'] ?? "",
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  bookings[i]['address'] ?? "",
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (bookings[i]['is_cancelled'] ==
                                              "1")
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                    color: Colors.red.shade200),
                                              ),
                                              child: Text(
                                                "Cancelled",
                                                style: TextStyle(
                                                  color: Colors.red.shade600,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),

                                      const SizedBox(height: 14),
                                      Divider(color: Colors.grey.shade200),
                                      const SizedBox(height: 10),

                                      // BOOKED ON + AMOUNT ROW
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.calendar_month,
                                                  size: 18,
                                                  color: Colors.grey.shade600),
                                              const SizedBox(width: 6),
                                              Text(
                                                "Booked On: ${bookings[i]['date']}",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                  color: Colors.green.shade200),
                                            ),
                                            child: Text(
                                              "₹ ${bookings[i]['amount']}",
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.green.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 12),

                                      // ACTIONS
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          if (bookings[i]['used'] == true)
                                            GestureDetector(
                                              onTap: () {
                                                submitRating(bookings[i]);
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 14,
                                                        vertical: 10),
                                                decoration: BoxDecoration(
                                                  color: Colors.red.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                      color:
                                                          Colors.red.shade200),
                                                ),
                                                child: Text(
                                                  "Add Review",
                                                  style: TextStyle(
                                                    color: Colors.red.shade600,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            )
                                          else
                                            const SizedBox(),
                                          Row(
                                            children: [
                                              Text(
                                                "View Details",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Icon(Icons.arrow_forward_ios,
                                                  size: 14,
                                                  color: Colors.grey.shade600),
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
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
      ),
    );
  }
}
