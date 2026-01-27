import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import '../helpers/helper_functions.dart';

// ignore: must_be_immutable
class SpecialChargeAddScreen extends StatefulWidget {
  SpecialChargeAddScreen(this.turfData, this.updateHome);
  Map turfData;
  Function updateHome;
  @override
  State<SpecialChargeAddScreen> createState() =>
      _SpecialChargeAddScreenState(this.turfData);
}

class _SpecialChargeAddScreenState extends State<SpecialChargeAddScreen> {
  _SpecialChargeAddScreenState(this.turfData);
  int selectedDayIndex = 0;
  int timeIndex = 0;
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

  TextEditingController _priceController = TextEditingController();
  @override
  void initState() {
    super.initState();
    getTurfDetails(context);
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

  addSpecialTurf() async {
    
    if (mounted)
      setState(() {
        isLoading = true;
      });
    var url = Uri.parse(Constants.base_url + 'Owner/add_turf_special_charges');
    var response = await http.post(url, body: {
      "userToken": Constants.token,
      "turf_id": turfData['id'],
      "date": turfDetails["dates"][selectedDayIndex]["full_date"],
      "start_time": slotList[timeIndex]["start"],
      "end_time": slotList[timeIndex]["end"],
      "price": _priceController.text
    });
    var body = jsonDecode(response.body);
    
    if (response.statusCode == 200) {
      if (mounted)
        setState(() {
          isLoading = false;
        });
      widget.updateHome();
      showSnackbar(context, body['message']);
      Navigator.pop(context);
    } else {
      showSnackbar(context, body['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade600,
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        title: Text(
          "Add Special Charges",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: BackButton(
          color: Colors.white,
        ),
      ),
      body: isLoading
          ? Column(
              children: [
                LinearProgressIndicator(
                  backgroundColor: Colors.white,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.green.shade600),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Loading...",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            )
          : SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Select Date ",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    SizedBox(
                      height: 25,
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
                                        highlightColor: Colors.grey.shade400,
                                        enabled: true,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
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
                                        print(turfDetails['dates'][i]
                                            ['full_date']);
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
                                            borderRadius: BorderRadius.all(
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
                                                      color:
                                                          selectedDayIndex == i
                                                              ? Colors.white
                                                              : Colors.black)),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                turfDetails['dates'][i]['date'],
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: selectedDayIndex == i
                                                        ? Colors.white
                                                        : Colors.red.shade400),
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
                              width: MediaQuery.of(context).size.width * 0.9,
                            ),
                          ),
                        ),
                    SizedBox(
                      height: 20,
                    ),
                    if (slotList.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Select Slot",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                    if (!isLoadingSlot)
                      for (var j = 0; j < slotList.length; j++)
                        GestureDetector(
                          onTap: () {
                            

                            timeIndex = j;
                            setState(() {});
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
                                color: j == timeIndex
                                    ? Colors.red.shade400
                                    : Colors.grey.shade100,
                              ),
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    slotList[j]['label'],
                                    style: TextStyle(
                                        color: j == timeIndex
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                  j == timeIndex
                                      ? Icon(
                                          Icons.check,
                                          color: Colors.white,
                                        )
                                      : SizedBox(),
                                ],
                              )),
                        ),
                    if (slotList.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            "No Slots Available",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    SizedBox(
                      height: 20,
                    ),
                    Divider(),
                    Text(
                      "Enter  Price",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: _priceController,
                      cursorColor: Colors.black,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.only(
                            left: 8, bottom: 0, top: 0, right: 15),
                        hintText: "Enter Special Turf Price",
                        hintStyle: TextStyle(
                            color: Colors.black54, fontWeight: FontWeight.w500),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Center(
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white)),
                        onPressed: () {
                          if (_priceController.text.isEmpty) {
                            showSnackbar(context, "Please Enter Price");
                          } else if (slotList.isEmpty) {
                            showSnackbar(context, "No Slots Available");
                          } else {
                            addSpecialTurf();
                          }
                        },
                        child: Text(
                          "Add Special Charges",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
