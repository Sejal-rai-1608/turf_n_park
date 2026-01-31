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
      parkingList = [];
      setState(() {});
    }
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          "Exit App?",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green.shade900,
          ),
        ),
        content: Text("Are you sure you want to exit the app?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () => exit(0),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text("Exit"),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor()
              ? Icons.star_rounded
              : Icons.star_outline_rounded,
          size: 16,
          color: index < rating.floor()
              ? Colors.amber.shade600
              : Colors.grey.shade400,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _showExitConfirmation();
        return false;
      },
      child: Scaffold(
        drawer: AppDrawer(),
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.green.shade600,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          title: GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .push(
                      MaterialPageRoute(builder: (context) => SelectLocation()))
                  .then((value) {
                if (value == true) {
                  getTurfs(context);
                }
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_rounded,
                      size: 18, color: Colors.white),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      Constants.fullLocation.isNotEmpty
                          ? Constants.fullLocation
                          : "Select Location",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down_rounded, color: Colors.white),
                ],
              ),
            ),
          ),
          actions: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  margin: EdgeInsets.only(right: 15),
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MyCart(
                              update: () {
                                setState(() {});
                              },
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.shopping_cart_rounded,
                          color: Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: -5,
                  child: Obx(
                    () => c.count.value > 0
                        ? Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.red.shade600,
                                  Colors.red.shade400
                                ],
                              ),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Text(
                              c.count.value.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : SizedBox(),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Search Bar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (v) => getTurfs(context),
                    controller: searchController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.search_rounded,
                          color: Colors.grey.shade500),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear_rounded,
                                  color: Colors.grey.shade500),
                              onPressed: () {
                                searchController.clear();
                                getTurfs(context);
                              },
                            )
                          : null,
                      hintText: 'Search parking spaces...',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),

              // Header with Filter
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Available Parkings",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "${parkingList.length} spots found",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(25)),
                          ),
                          backgroundColor: Colors.white,
                          context: context,
                          builder: (context) {
                            return Container(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Container(
                                      width: 40,
                                      height: 4,
                                      margin: EdgeInsets.only(bottom: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "Filter by Vehicle Type",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade900,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  ...['2 Wheeler', '4 Wheeler', 'Clear Filter']
                                      .map((option) {
                                    return ListTile(
                                      onTap: () {
                                        setState(() {
                                          if (option == 'Clear Filter') {
                                            filter = "";
                                          } else {
                                            filter = option;
                                          }
                                        });
                                        Navigator.of(context).pop();
                                        getTurfs(context);
                                      },
                                      leading: option == '2 Wheeler'
                                          ? Icon(Icons.motorcycle_rounded,
                                              color: Colors.blue.shade700)
                                          : option == '4 Wheeler'
                                              ? Icon(
                                                  Icons.directions_car_rounded,
                                                  color: Colors.green.shade700)
                                              : Icon(
                                                  Icons.filter_alt_off_rounded,
                                                  color: Colors.grey.shade600),
                                      title: Text(
                                        option,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                      trailing: filter == option
                                          ? Icon(Icons.check_circle_rounded,
                                              color: Colors.green.shade600)
                                          : null,
                                    );
                                  }).toList(),
                                  SizedBox(height: 20),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.05),
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.filter_alt_rounded,
                              size: 20,
                              color: Colors.green.shade700,
                            ),
                            SizedBox(width: 8),
                            Text(
                              filter.isEmpty ? "Filter" : filter,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return ListView.builder(
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 16),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade200,
              highlightColor: Colors.grey.shade100,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          );
        },
      );
    }

    if (parkingList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_parking_rounded,
              size: 80,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: 20),
            Text(
              "No Parking Spaces Found",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Try changing your location or filters",
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  filter = "";
                  searchController.clear();
                });
                getTurfs(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text("Clear Filters"),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(bottom: 20),
      itemCount: parkingList.length,
      itemBuilder: (context, index) {
        final parking = parkingList[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ParkingDetails(parking),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 16),
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Background Image
                  Positioned.fill(
                    child: Image.network(
                      parking['main_image'] ?? '',
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.local_parking_rounded,
                            size: 60,
                            color: Colors.grey.shade400,
                          ),
                        );
                      },
                    ),
                  ),

                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.5),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top Row - Title and Rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    parking['title'] ?? 'Parking Space',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_rounded,
                                        size: 14,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          parking['address'] ?? '',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                Colors.white.withOpacity(0.9),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (parking['rating'] != null)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      size: 14,
                                      color: Colors.amber.shade400,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      parking['rating'].toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),

                        // Bottom Row - Type and Book Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Container(
                            //   padding: EdgeInsets.symmetric(
                            //       horizontal: 12, vertical: 6),
                            //   decoration: BoxDecoration(
                            //     color: Colors.white.withOpacity(0.9),
                            //     borderRadius: BorderRadius.circular(10),
                            //   ),
                            //   child: Row(
                            //     children: [
                            // Icon(
                            //   parking['parking_type']?.contains('2') ??
                            //           false
                            //       ? Icons.motorcycle_rounded
                            //       : Icons.directions_car_rounded,
                            //   size: 16,
                            //   color: Colors.green.shade700,
                            // ),
                            // SizedBox(width: 6),
                            // Text(
                            //   parking['parking_type'] ?? 'Parking',
                            //   style: TextStyle(
                            //     fontSize: 12,
                            //     fontWeight: FontWeight.w600,
                            //     color: Colors.green.shade800,
                            //   ),
                            //       // ),
                            //     ],
                            //   ),
                            // ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green.shade600,
                                    Colors.green.shade700,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.shade200,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                "Book Now",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
