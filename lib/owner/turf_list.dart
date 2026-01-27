import 'dart:developer';

import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:turfandpark/owner/add_turf_screen.dart';
import 'package:turfandpark/owner/edit_turf_screen.dart';
import 'package:turfandpark/owner/special_charges_list.dart';
// import 'game_filter.dart';
import '../helpers/helper_functions.dart';
// import 'notifications.dart';
// import 'turf_details.dart';
import '../helpers/owner_drawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import 'dart:io' show Platform, exit;
import 'package:flutter/services.dart';

import 'turf_schedule.dart';

class OwnerTurfList extends StatefulWidget {
  static const String id = 'OwnerTurfList_screen';
  const OwnerTurfList({Key? key}) : super(key: key);

  @override
  State<OwnerTurfList> createState() => _OwnerTurfListState();
}

class _OwnerTurfListState extends State<OwnerTurfList> {
  List turfList = [];
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

    var url = Uri.parse(Constants.base_url + 'Service/get_my_turfs');
    var response = await http.post(url, body: {"userToken": Constants.token});
    var body = jsonDecode(response.body);
    log(body.toString());
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
      showSnackbar(context, body['message']);
      turfList = [];
      setState(() {});
    }
  }

  getTurfsActive({required bool active, required String turfId}) async {
    setState(() {
      isLoading = true;
    });

    var url = Uri.parse(Constants.base_url +
        'Owner/${active ? "activate_turf" : "deactivate_turf"}');
    var response = await http.post(url, body: {
      "userToken": Constants.token,
      "turf_id": turfId,
    });
    var body = jsonDecode(response.body);

    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      var list = body['message'];
      getTurfs(context);
    } else if (response.statusCode == 401) {
      showSnackbar(context, body['message']);
      onLogout(context);
    } else {
      showSnackbar(context, body['message']);
      turfList = [];
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
                builder: (context) => AddTurfScreen(
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
              "Your Turfs",
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
                if (isLoading || turfList.length > 0)
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
                            builder: (context) => TurfSchedule(turfList[i])));
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
                                    Text(turfList[i]['turf_name'],
                                        overflow: TextOverflow.clip,
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          // backgroundColor: Colors.black45
                                        )),
                                    Text(turfList[i]['address'],
                                        style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                                Spacer(),
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
                                                  EditTurfScreen(
                                                    turfData: turfList[i],
                                                  )));
                                    },
                                    icon: Icon(Icons.edit, color: Colors.white),
                                    label: Text("Edit",
                                        style: TextStyle(color: Colors.white)))
                              ],
                            ),
                          ),
                          Positioned(
                            right: 10,
                            top: 60,
                            child: ElevatedButton.icon(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                  ),
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.green.shade600),
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          SpecialChargesListScreen(
                                            turf: turfList[i],
                                          )));
                                },
                                icon: Icon(Icons.attach_money,
                                    color: Colors.white),
                                label: Text("Special Charges",
                                    style: TextStyle(color: Colors.white))),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
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
                                        child: Text("Details",
                                            style: TextStyle(
                                                fontSize: 17,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                    )),
                                Spacer(),
                                InkWell(
                                  onTap: () {
                                    getTurfsActive(
                                      active: turfList[i]['active'] == '0'
                                          ? true
                                          : false,
                                      turfId: turfList[i]['id'],
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
                                        color: turfList[i]['active'] != '0'
                                            ? Colors.red.shade600
                                            : Colors.green.shade600,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                          turfList[i]['active'] == '0'
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
