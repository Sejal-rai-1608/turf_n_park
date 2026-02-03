import 'dart:convert';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:turfandpark/pages/my_cart.dart';
import 'package:turfandpark/pages/turfList.dart';
import 'package:zoom_pinch_overlay/zoom_pinch_overlay.dart';
import '../helpers/helper_functions.dart';

class TurfDetails extends StatefulWidget {
  Map turfData;
  VoidCallback update;

  TurfDetails(
    this.turfData,
    this.update,
  );

  @override
  State<TurfDetails> createState() => _TurfDetailsState(this.turfData);
}

class _TurfDetailsState extends State<TurfDetails> {
  _TurfDetailsState(this.turfData);
  int selectedDayIndex = 0;
  Map turfData;
  Map turfDetails = {};
  List slotList = [];
  bool isLoading = false;
  bool isLoadingSlot = false;
  int _currentCarouselIndex = 0;

  @override
  void initState() {
    super.initState();
    getTurfDetails(context);
    c.getCartCount(context);
  }

  List<String> listImages = [];
  getTurfDetails(context) async {
    listImages = [];
    var temp = widget.turfData['slider_images'].toString().split(',');
    listImages = temp;
    listImages.add(widget.turfData['main_image']);
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
      c.getCartCount(context);
      widget.update();

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

  updateTurfList() {
    getTurfSlots(context, turfDetails["dates"][selectedDayIndex]["full_date"]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20.w),
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () => {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => MyCart(
                            update: updateTurfList,
                          )))
                },
                icon: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.shopping_cart_rounded,
                      color: Colors.white, size: 20.w),
                ),
              ),
              Positioned(
                right: 8.w,
                top: 8.h,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.shade500,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.shade300,
                        blurRadius: 3.w,
                        spreadRadius: 1.w,
                      ),
                    ],
                  ),
                  child: Obx(
                    () => Text(
                      c.count.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 18.w,
              color: Colors.white,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          turfData['turf_name'],
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              // Enhanced Carousel Slider
              Container(
                height: 0.28.sh,
                width: double.infinity,
                child: Stack(
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 4),
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                        enlargeCenterPage: true,
                        viewportFraction: 1.0,
                        height: 0.28.sh,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentCarouselIndex = index;
                          });
                        },
                      ),
                      items: listImages.map((i) {
                        return Builder(
                          builder: (BuildContext context) {
                            return InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                      backgroundColor: Colors.transparent,
                                      insetPadding: EdgeInsets.all(20.w),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20.w),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.3),
                                                  blurRadius: 30.w,
                                                  spreadRadius: 5.w,
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20.w),
                                              child: ZoomOverlay(
                                                twoTouchOnly: true,
                                                child: Container(
                                                  color: Colors.black,
                                                  child: FancyShimmerImage(
                                                    imageUrl: i,
                                                    errorWidget: Image.asset(
                                                      "assets/logo.png",
                                                      fit: BoxFit.contain,
                                                    ),
                                                    boxFit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 15.h),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              foregroundColor:
                                                  Colors.green.shade700,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.w),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 30.w,
                                                  vertical: 12.h),
                                            ),
                                            child: Text(
                                              "Close",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14.sp,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                child: Stack(
                                  children: [
                                    FancyShimmerImage(
                                      imageUrl: i,
                                      errorWidget: Image.asset(
                                        "assets/logo.png",
                                        fit: BoxFit.fill,
                                      ),
                                      boxFit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.3),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),

                    // Image Indicator
                    Positioned(
                      bottom: 15.h,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: listImages.asMap().entries.map((entry) {
                          return AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            width:
                                _currentCarouselIndex == entry.key ? 20.w : 8.w,
                            height: 8.h,
                            margin: EdgeInsets.symmetric(horizontal: 3.w),
                            decoration: BoxDecoration(
                              color: _currentCarouselIndex == entry.key
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4.w),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 3.w,
                                  offset: Offset(0, 1.h),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // Image Counter
                    Positioned(
                      top: 15.h,
                      right: 15.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20.w),
                        ),
                        child: Text(
                          '${_currentCarouselIndex + 1}/${listImages.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content Container with modern design
              Positioned(
                top: 0.23.sh,
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.w),
                      topRight: Radius.circular(30.w),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 25.w,
                        spreadRadius: 5.w,
                        offset: Offset(0, -5.h),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Turf Name and Price - Modern Design
                          Container(
                            margin: EdgeInsets.only(bottom: 10.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        turfData['turf_name'],
                                        style: TextStyle(
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade900,
                                          height: 1.2,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 18.w,
                                            color: Colors.grey.shade600,
                                          ),
                                          SizedBox(width: 6.w),
                                          Flexible(
                                            child: Text(
                                              turfData['address'],
                                              style: TextStyle(
                                                color: Colors.grey.shade700,
                                                fontSize: 14.sp,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(width: 6.w),
                                          Container(
                                            height: 15.h,
                                            width: 1.w,
                                            color: Colors.grey.shade500,
                                          ),
                                          Icon(
                                            Icons.star,
                                            color: Colors.amber.shade700,
                                            size: 18.w,
                                          ),
                                          Text(
                                            turfData['rating'] == null
                                                ? "No Ratings"
                                                : turfData['rating'].toString(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.amber.shade900,
                                              fontSize: 15.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.w, vertical: 10.h),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.green.shade500,
                                        Colors.green.shade700,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12.w),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.shade200,
                                        blurRadius: 10.w,
                                        offset: Offset(0, 4.h),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    "Rs." +
                                        (int.parse(turfData['hourly_rent']))
                                            .toString(),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 10.h),

                          if (turfDetails['amenities'] != null &&
                              turfDetails['amenities'].length > 0)
                            Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.w),
                                border: Border.all(
                                  color: Colors.grey.shade100,
                                  width: 1.5.w,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.05),
                                    blurRadius: 15.w,
                                    spreadRadius: 5.w,
                                    offset: Offset(0, 5.h),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(10.w),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius:
                                              BorderRadius.circular(12.w),
                                        ),
                                        child: Icon(
                                          Icons.emoji_events_rounded,
                                          color: Colors.blue.shade700,
                                          size: 15.w,
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Text(
                                        "Amenities & Facilities",
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade900,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 16.h),

                                  // Grid view for amenities
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 10.w,
                                      childAspectRatio: 5,
                                    ),
                                    itemCount: turfDetails['amenities'].length,
                                    itemBuilder: (context, index) {
                                      return Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle_rounded,
                                            size: 18.w,
                                            color: Colors.green.shade600,
                                          ),
                                          SizedBox(width: 8.w),
                                          Expanded(
                                            child: Text(
                                              turfDetails['amenities'][index]
                                                      ['text'] ??
                                                  '',
                                              style: TextStyle(
                                                color: Colors.green.shade800,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 13.sp,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                          // If no amenities, show a message
                          if (turfDetails['amenities'] == null ||
                              turfDetails['amenities'].length == 0)
                            Container(
                              padding: EdgeInsets.all(20.w),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(20.w),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.emoji_events_outlined,
                                    color: Colors.grey.shade500,
                                    size: 18.w,
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      "No amenities listed",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          SizedBox(height: 10.h),

                          // Owner Section - Enhanced
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.w),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1.5.w,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade100,
                                  blurRadius: 10.w,
                                  offset: Offset(0, 4.h),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "OWNER",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade600,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                Container(
                                  height: 24.h,
                                  width: 1.w,
                                  margin:
                                      EdgeInsets.symmetric(horizontal: 12.w),
                                  color: Colors.grey.shade300,
                                ),
                                Expanded(
                                  child: isLoading
                                      ? Shimmer.fromColors(
                                          baseColor: Colors.grey.shade200,
                                          highlightColor: Colors.grey.shade100,
                                          child: Container(
                                            height: 20.h,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(4.w),
                                            ),
                                          ),
                                        )
                                      : Text(
                                          turfDetails['turf_owner_name'] ??
                                              'Loading...',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green.shade900,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 10.h),

                          // Availability Section - Enhanced
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    color: Colors.green.shade700,
                                    size: 20.w,
                                  ),
                                  SizedBox(width: 10.w),
                                  Text(
                                    "Availability",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade900,
                                    ),
                                  ),
                                ],
                              ),

                              // Date Selector - Enhanced
                              Container(
                                height: 90.h,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      if (isLoading)
                                        for (var i = 0; i <= 6; i++)
                                          Container(
                                            width: 60.w,
                                            height: 60.w,
                                            margin:
                                                EdgeInsets.only(right: 10.w),
                                            child: Shimmer.fromColors(
                                              baseColor: Colors.grey.shade200,
                                              highlightColor:
                                                  Colors.grey.shade100,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.w),
                                                ),
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
                                                    ['full_date'],
                                              );
                                            },
                                            child: Container(
                                              width: 60.w,
                                              height: 60.w,
                                              margin:
                                                  EdgeInsets.only(right: 10.w),
                                              decoration: BoxDecoration(
                                                color: selectedDayIndex == i
                                                    ? Colors.green.shade500
                                                    : Colors.grey.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(12.w),
                                                border: Border.all(
                                                  color: selectedDayIndex == i
                                                      ? Colors.green.shade500
                                                      : Colors.grey.shade300,
                                                  width: 1.5.w,
                                                ),
                                                boxShadow: selectedDayIndex == i
                                                    ? [
                                                        BoxShadow(
                                                          color: Colors
                                                              .green.shade200,
                                                          blurRadius: 10.w,
                                                          offset:
                                                              Offset(0, 4.h),
                                                        ),
                                                      ]
                                                    : null,
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    turfDetails['dates'][i]
                                                            ['month'] ??
                                                        '',
                                                    style: TextStyle(
                                                      fontSize: 10.sp,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          selectedDayIndex == i
                                                              ? Colors.white
                                                              : Colors.grey
                                                                  .shade700,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4.h),
                                                  Text(
                                                    turfDetails['dates'][i]
                                                            ['date'] ??
                                                        '',
                                                    style: TextStyle(
                                                      fontSize: 18.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          selectedDayIndex == i
                                                              ? Colors.white
                                                              : Colors.green
                                                                  .shade700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: 20.h),

                              // Time Slots - Enhanced
                              if (isLoading || isLoadingSlot)
                                for (var j = 0; j < 3; j++)
                                  Container(
                                    margin: EdgeInsets.only(bottom: 12.h),
                                    child: Shimmer.fromColors(
                                      baseColor: Colors.grey.shade200,
                                      highlightColor: Colors.grey.shade100,
                                      child: Container(
                                        height: 65.h,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12.w),
                                        ),
                                      ),
                                    ),
                                  ),
                              if (!isLoadingSlot)
                                for (var j = 0; j < slotList.length; j++)
                                  GestureDetector(
                                    onTap: () {
                                      if (slotList[j]['is_booked']) {
                                        showSnackbar(context,
                                            "This Slot is Already Booked.");
                                      } else if (slotList[j]['is_in_my_cart']) {
                                        showSnackbar(context,
                                            "This Slot is Already in your cart.");
                                      } else {
                                        addToCart(
                                          context,
                                          turfDetails["dates"][selectedDayIndex]
                                              ['full_date'],
                                          slotList[j]['start'],
                                          slotList[j]['end'],
                                          slotList[j]['rent'],
                                          j,
                                        );
                                      }
                                    },
                                    child: Container(
                                      height: 70.h,
                                      margin: EdgeInsets.only(bottom: 12.h),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.w, vertical: 12.h),
                                      decoration: BoxDecoration(
                                        color:
                                            slotList[j]['is_in_my_cart'] == true
                                                ? Colors.green.shade50
                                                : Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12.w),
                                        border: Border.all(
                                          color: slotList[j]['is_booked'] ==
                                                  true
                                              ? Colors.red.shade300
                                              : (slotList[j]['is_in_my_cart'] ==
                                                      true
                                                  ? Colors.green.shade400
                                                  : Colors.grey.shade300),
                                          width: 1.5.w,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.shade100,
                                            blurRadius: 8.w,
                                            offset: Offset(0, 4.h),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                slotList[j]['label'] ?? '',
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: slotList[j][
                                                              'is_in_my_cart'] ==
                                                          true
                                                      ? Colors.green.shade800
                                                      : Colors.black87,
                                                ),
                                              ),
                                              if (slotList[j]['description'] !=
                                                  null)
                                                SizedBox(height: 4.h),
                                              if (slotList[j]['description'] !=
                                                  null)
                                                Text(
                                                  slotList[j]['description'],
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16.w,
                                                vertical: 8.h),
                                            decoration: BoxDecoration(
                                              color: slotList[j]
                                                          ['is_in_my_cart'] ==
                                                      true
                                                  ? Colors.green.shade500
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8.w),
                                              border: Border.all(
                                                color: slotList[j]
                                                            ['is_in_my_cart'] ==
                                                        true
                                                    ? Colors.green.shade500
                                                    : (slotList[j]
                                                                ['is_booked'] ==
                                                            true
                                                        ? Colors.red.shade300
                                                        : Colors
                                                            .green.shade500),
                                                width: 1.5.w,
                                              ),
                                            ),
                                            child: Text(
                                              slotList[j]['is_booked'] == true
                                                  ? "Booked"
                                                  : "Rs." +
                                                      slotList[j]['rent']
                                                          .toString(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14.sp,
                                                color: slotList[j]
                                                            ['is_in_my_cart'] ==
                                                        true
                                                    ? Colors.white
                                                    : (slotList[j]
                                                                ['is_booked'] ==
                                                            true
                                                        ? Colors.red.shade500
                                                        : Colors
                                                            .green.shade700),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                              SizedBox(height: 30.h),
                            ],
                          ),
                        ],
                      ),
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
