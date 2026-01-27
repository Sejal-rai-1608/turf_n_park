import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:turfandpark/helpers/helper_functions.dart';
import 'package:http/http.dart' as http;
import 'package:turfandpark/owner/special_charges_screen_add.dart';

class SpecialChargesListScreen extends StatefulWidget {
  final Map turf;
  SpecialChargesListScreen({Key? key, required this.turf}) : super(key: key);

  @override
  State<SpecialChargesListScreen> createState() =>
      _SpecialChargesListScreenState();
}

class _SpecialChargesListScreenState extends State<SpecialChargesListScreen> {
  List turfList = [];
  bool isLoading = false;
  String games = "";
  @override
  void initState() {
    super.initState();
    getSpecialTurfs(context);
  }

  updateHome() {
    getSpecialTurfs(context);
  }

  getSpecialTurfs(context) async {
    setState(() {
      isLoading = true;
    });

    var url = Uri.parse(Constants.base_url + 'Owner/turf_special_charges_list');
    var response = await http.post(url,
        body: {"userToken": Constants.token, "turf_id": widget.turf["id"]});
    var body = jsonDecode(response.body);
    log(body.toString());
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      var list = body['message'];

      if (list == "[]") {
        setState(() {
          turfList = [];
        });
      } else {
        setState(() {
          turfList = list;
        });
      }
    } else if (response.statusCode == 401) {
      showSnackbar(context, body['message']);
      onLogout(context);
    } else {
      turfList = [];

      setState(() {});
      showSnackbar(context, body['message']);
    }
  }

  deleteSpecialTurfs(id) async {
    var url =
        Uri.parse(Constants.base_url + 'Owner/delete_turf_special_charges');
    var response =
        await http.post(url, body: {"userToken": Constants.token, "id": id});
    var body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      updateHome();
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
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        title: Text(
          "Special Charges",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: BackButton(
          color: Colors.white,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () {
              updateHome();
            },
          ),
          IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      SpecialChargeAddScreen(widget.turf, updateHome)));
            },
          ),
        ],
      ),
      body:turfList.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Lottie.asset("assets/84854-empty.json",
                        height: 250, width: double.infinity),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "No Special Charges !",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Colors.green.shade600)),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => SpecialChargeAddScreen(
                                  widget.turf, updateHome)));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Add Special Charges",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ))
                  ],
                )
              : ListView.builder(
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text("Price: " + turfList[index]['price'] + " "),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Date: " + turfList[index]['date']),
                            Text("From: " +
                                turfList[index]['start_time'] +
                                " to " +
                                turfList[index]['end_time']),
                          ],
                        ),
                        trailing: IconButton(
                            color: Colors.redAccent,
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: Text("Are you sure ?"),
                                        content: Text(
                                            "Do you want to delete this special charge ?"),
                                        actions: [
                                          ElevatedButton(
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.green.shade600)),
                                            child: Text(
                                              "Cancel",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          ElevatedButton(
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.red.shade600)),
                                            child: Text(
                                              "Delete",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            onPressed: () {
                                              deleteSpecialTurfs(
                                                  turfList[index]['id']);
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      ));
                            }),
                      ),
                    );
                  },
                  itemCount: turfList.length,
                ),
    );
  }
}
