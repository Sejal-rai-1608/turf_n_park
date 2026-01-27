import 'dart:convert';
import 'dart:developer';
import 'dart:io' show Platform, exit;

import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:turfandpark/owner/edit_parking_screen.dart';

// import 'game_filter.dart';
import '../helpers/helper_functions.dart';
// import 'notifications.dart';
// import 'turf_details.dart';
import '../helpers/owner_drawer.dart';
import '../pages/parking_details_owner.dart';
import 'add_parking_screen.dart';

class ParkingListList extends StatefulWidget {
  static const String id = 'OwnerTurfList_screen';
  const ParkingListList({Key? key}) : super(key: key);

  @override
  State<ParkingListList> createState() => _ParkingListListState();
}

class _ParkingListListState extends State<ParkingListList> {
  List parkingList = [];
  bool isLoading = false;
  String games = "";
  @override
  void initState() {
    super.initState();
    getTurfs(context);
  }

  updateHome() {
    getTurfs(context);
  }

  getTurfs(context) async {
    setState(() {
      isLoading = true;
    });

    var url = Uri.parse(Constants.base_url + 'Service/get_my_parkings');
    var response = await http.post(url, body: {"userToken": Constants.token});
    var body = jsonDecode(response.body);
    log(body.toString());
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
      showSnackbar(context, body['message']);
      parkingList = [];
      setState(() {});
    }
  }

  getParkingActive({required bool active, required String parkingID}) async {
    setState(() {
      isLoading = true;
    });

    var url = Uri.parse(Constants.base_url +
        'Owner/${active ? "activate_parking" : "deactivate_parking"}');
    var response = await http.post(url, body: {
      "userToken": Constants.token,
      "parking_id": parkingID,
    });
    var body = jsonDecode(response.body);

    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      var list = body['message'];
      showSnackbar(context, body['message']);
      getTurfs(context);
    } else if (response.statusCode == 401) {
      showSnackbar(context, body['message']);
      onLogout(context);
    } else {
      showSnackbar(context, body['message']);
      parkingList = [];
      setState(() {});
    }
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = ElevatedButton(
      child: Text("Exit"),
      onPressed: () {
        Navigator.of(context).pop();
        if (Platform.isAndroid) {
          SystemNavigator.pop();
        } else if (Platform.isIOS) {
          exit(0);
        }
      },
    );

    Widget cancelButton = ElevatedButton(
      child: Text("No"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Confirm !"),
      content: Text("Are you sure you want to exit app ?"),
      actions: [
        okButton,
        cancelButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // function
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ParkingAddScreen(
                      updateHome: updateHome,
                    )));
          },
          backgroundColor: Colors.green.shade600,
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.white,
        drawer: OwnerAppDrawer(),
        appBar: AppBar(
            backgroundColor: Colors.green.shade600,
            // toolbarHeight: 100,
            iconTheme: IconThemeData(color: Colors.white),
            elevation: 0.0,
            title: Text(
              "Your Parkings",
              style: TextStyle(color: Colors.white),
            )),
        body: WillPopScope(
          onWillPop: () {
            showAlertDialog(context);
            return Future.value(false); // if true allow back else block it
          },
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(children: [
                if (isLoading || parkingList.length > 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [],
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
                            Text("No Parking Found",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 22)),
                          ],
                        ),
                      ),
                    ],
                  ),
                if (!isLoading)
                  for (var i = 0; i < parkingList.length; i++)
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ParkingDetailsOwner(
                                parkingList[i], updateHome)));
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
                              imageUrl: parkingList[i]['main_image'],
                              boxFit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              color: Colors.black.withOpacity(0.2),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(parkingList[i]['title'],
                                        overflow: TextOverflow.clip,
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          // backgroundColor: Colors.black45
                                        )),
                                    Text(parkingList[i]['address'],
                                        style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                                Spacer(),
                                Column(
                                  children: [
                                    ElevatedButton.icon(
                                        style: ButtonStyle(
                                          shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20))),
                                          ),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.green.shade600),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditParkingScreen(
                                                        update: updateHome,
                                                        turfData:
                                                            parkingList[i],
                                                      )));
                                        },
                                        icon: Icon(Icons.edit,
                                            color: Colors.white),
                                        label: Text("Edit",
                                            style: TextStyle(
                                                color: Colors.white))),
                                    Spacer(),
                                    InkWell(
                                      onTap: () {
                                        getParkingActive(
                                          active:
                                              parkingList[i]['active'] == '0'
                                                  ? true
                                                  : false,
                                          parkingID: parkingList[i]['id'],
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          height: 34,
                                          alignment: Alignment.bottomRight,
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20)),
                                            color:
                                                parkingList[i]['active'] != '0'
                                                    ? Colors.red.shade600
                                                    : Colors.green.shade600,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text(
                                              parkingList[i]['active'] == '0'
                                                  ? "Activate"
                                                  : "Deactivate",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ]),
                      ),
                    ),
              ]),
            ),
          ),
        ));
  }
// Widget create
}
