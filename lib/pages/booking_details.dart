import 'dart:convert';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../helpers/helper_functions.dart';

class BookingDetails extends StatefulWidget {
  BookingDetails(this.bookingDetails);
  var bookingDetails;

  @override
  State<BookingDetails> createState() =>
      _BookingDetailsState(this.bookingDetails);
}

class _BookingDetailsState extends State<BookingDetails> {
  _BookingDetailsState(this.bookingDetails);
  var bookingDetails;
  bool isCancel = false;
  String invoiceString = '';
  bool isLoading = false;
  Map bookingData = {};
  List slotList = [];

  @override
  void initState() {
    super.initState();
    getBookingDetails(context);
  }

  Future<void> _launchUrl() async {
    if (invoiceString.isEmpty) {
      showSnackbar(context, "Invoice not available!");
      return;
    }

    final Uri url = Uri.parse(invoiceString);

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      showSnackbar(context, "Could not open invoice");
    }
  }

  getBookingDetails(context) async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    var url = Uri.parse(Constants.base_url + 'Service/booking_details');
    var response = await http.post(url, body: {
      "userToken": Constants.token,
      "booking_id": bookingDetails['id']
    });

    if (mounted) {
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        setState(() {
          bookingData = body['message'];
        });
// ✅ Take invoice url directly
        invoiceString = bookingData['url']?.toString() ?? "";
        print("Invoice URL: $invoiceString");

        // ✅ DEBUG HERE
        print("Booking Details API Response: $body");
        print("Encoded Invoice String: ${body['encoded_string']}");

        isCancel = body['can_cancel'] == "true";

        invoiceString = body['message']['url']?.toString() ?? "";
        print("Invoice URL: $invoiceString");

        setState(() {
          bookingData = body['message'];
        });
      } else {
        var body = jsonDecode(response.body);

        // ✅ DEBUG HERE ALSO
        print("Booking Details API Error: $body");

        showSnackbar(context, body['message'].toString());
        setState(() {
          bookingData = {};
        });
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  requestCancellation(context) async {
    if (mounted)
      setState(() {
        isLoading = true;
      });

    var url = Uri.parse(Constants.base_url + 'Service/request_cancellation');
    var response = await http.post(url, body: {
      "userToken": Constants.token,
      "booking_id": bookingDetails['id']
    });

    if (mounted) {
      var body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        showSnackbar(context, body['message']);
        Navigator.of(context).pop(true);
      } else {
        showSnackbar(context, body['message']);
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showCancellationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.w),
        ),
        title: Text(
          "Cancel Booking?",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red.shade700,
            fontSize: 18.sp,
          ),
        ),
        content: Text(
          "Are you sure you want to request cancellation for this booking?",
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "No",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              requestCancellation(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.w),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 10.h,
              ),
            ),
            child: Text(
              "Yes, Cancel",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.green.shade600,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(25.w),
            ),
          ),
          leading: Container(
            margin: EdgeInsets.only(left: 10.w),
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              radius: 20.w,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  size: 18.w,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          title: Text(
            "Booking Details",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18.sp,
            ),
          ),
          centerTitle: true,
        ),
        body: Container(
          color: Colors.white,
          child: Column(
            children: [
              // Header Image
              if (bookingDetails['image'] != null)
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    child: FancyShimmerImage(
                      imageUrl: bookingDetails['image'] ?? '',
                      errorWidget: Container(
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.image_outlined,
                          size: 60.w,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      boxFit: BoxFit.cover,
                    ),
                  ),
                ),

              // Content Section
              Expanded(
                flex: 7,
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
                        blurRadius: 20.w,
                        offset: Offset(0, -5.h),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Booking Info Card
                        Container(
                          padding: EdgeInsets.all(16.w),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "BOOKING #${bookingDetails['booking_no'] ?? ''}",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                bookingDetails['title'] ?? 'Booking',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade900,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 12.h),
                              Divider(
                                  color: Colors.grey.shade200, thickness: 1.w),
                              SizedBox(height: 12.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Amount Paid",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    "₹${bookingDetails['amount'] ?? '0'}",
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20.h),

                        // Owner Details Card
                        Container(
                          padding: EdgeInsets.all(16.w),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "CONTACT DETAILS",
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              if (bookingData["owner_details"] != null &&
                                  !isLoading)
                                Row(
                                  children: [
                                    Container(
                                      width: 50.w,
                                      height: 50.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.green.shade100,
                                            Colors.blue.shade100,
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.shade200,
                                            blurRadius: 8.w,
                                            offset: Offset(0, 4.h),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.person_outline_rounded,
                                          size: 28.w,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 15.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            bookingData["owner_details"]
                                                    ['name'] ??
                                                '',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green.shade900,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            bookingData["owner_details"]
                                                    ['mobile'] ??
                                                '',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.grey.shade700,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              else if (isLoading)
                                Row(
                                  children: [
                                    Container(
                                      width: 50.w,
                                      height: 50.w,
                                      child: Shimmer.fromColors(
                                        baseColor: Colors.grey.shade300,
                                        highlightColor: Colors.grey.shade100,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 15.w),
                                    Expanded(
                                      child: Shimmer.fromColors(
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
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),

                        //  SizedBox(height: 20.h),

                        // Booking Slots Section
                        if (bookingData["details"] != null &&
                            bookingData['details'].length > 0)
                          Container(
                            margin: EdgeInsets.only(top: 20.h),
                            padding: EdgeInsets.all(16.w),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(10.w),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius:
                                            BorderRadius.circular(12.w),
                                      ),
                                      child: Icon(
                                        Icons.calendar_today_rounded,
                                        color: Colors.green.shade700,
                                        size: 16.w,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Text(
                                        "Booking Schedule",
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16.h),
                                if (isLoading)
                                  for (var i = 0; i < 3; i++)
                                    Container(
                                      margin: EdgeInsets.only(bottom: 10.h),
                                      child: Shimmer.fromColors(
                                        baseColor: Colors.grey.shade200,
                                        highlightColor: Colors.grey.shade100,
                                        child: Container(
                                          height: 60.h,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12.w),
                                          ),
                                        ),
                                      ),
                                    ),
                                if (!isLoading)
                                  ...bookingData['details'].map((slot) {
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 10.h),
                                      padding: EdgeInsets.all(12.w),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius:
                                            BorderRadius.circular(12.w),
                                        border: Border.all(
                                          color: Colors.green.shade200,
                                          width: 1.5.w,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                slot['date_show'] ?? '',
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green.shade900,
                                                ),
                                              ),
                                              SizedBox(height: 4.h),
                                              Text(
                                                "Booking Date",
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                slot['label'] ?? '',
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green.shade900,
                                                ),
                                              ),
                                              SizedBox(height: 4.h),
                                              Text(
                                                "Time Slot",
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                              ],
                            ),
                          ),

                        SizedBox(height: 20.h),

                        // Actions Section
                        Container(
                          padding: EdgeInsets.all(16.w),
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
                          child: Column(
                            children: [
                              // Invoice Button
                              ElevatedButton(
                                onPressed: (isLoading || invoiceString.isEmpty)
                                    ? null
                                    : _launchUrl,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade600,
                                  minimumSize: Size(double.infinity, 55.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.w),
                                  ),
                                ),
                                child: Text(
                                  invoiceString.isEmpty
                                      ? "LOADING INVOICE..."
                                      : "VIEW INVOICE",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              SizedBox(height: 15.h),

                              // Cancellation Button
                              if (!isLoading && isCancel == true)
                                OutlinedButton(
                                  onPressed: () =>
                                      _showCancellationDialog(context),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: Colors.red.shade400,
                                      width: 2.w,
                                    ),
                                    minimumSize: Size(double.infinity, 55.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.w),
                                    ),
                                    backgroundColor: Colors.red.shade50,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.cancel_outlined,
                                        size: 20.w,
                                        color: Colors.red.shade600,
                                      ),
                                      SizedBox(width: 10.w),
                                      Text(
                                        "REQUEST CANCELLATION",
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),

                        SizedBox(height: 30.h),
                      ],
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
