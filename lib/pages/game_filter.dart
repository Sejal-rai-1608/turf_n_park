import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../helpers/helper_functions.dart';
import '../helpers/widgets.dart';

// import 'pre_login_owner.dart';
class GameFilter extends StatefulWidget {
  GameFilter(this.selectedGames);
  String selectedGames;
  @override
  State<GameFilter> createState() => _GameFilterState();
}

class _GameFilterState extends State<GameFilter> {
  bool isLoading = false;

  var games = [];
  List values = [];

  var SelectedGames = "";

  @override
  void initState() {
    super.initState();
    getGames(context);
  }

  getGames(context) async {
    setState(() {
      isLoading = true;
    });
    var url = Uri.parse(Constants.base_url + 'Service/games_list');
    var response = await http.post(url, body: {});
    var body = jsonDecode(response.body);

    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      var list = body['message'];
      List selectedArr = [];
      if (widget.selectedGames.length > 0)
        selectedArr = widget.selectedGames.split(",");
      for (var i = 0; i < list.length; i++)
        //  values.
        if (selectedArr.contains(list[i]['id']))
          values.add(true);
        else
          values.add(false);

      setState(() {
        games = list;
      });
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
        backgroundColor: Colors.green.shade500,
        elevation: 0,
        title: Text(
          "Select Games",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: isLoading
              ? Column(
                  children: [
                    LinearProgressIndicator(
                      backgroundColor: Colors.white,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Image.asset(
                      'assets/taxi-waiting.png',
                    ),
                    Text("Loading....",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold))
                  ],
                )
              : Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // SizedBox(height: 10,),

                    // Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     // alignment: Alignment.topRight,
                    //     children: [
                    //       Padding(
                    //           padding: EdgeInsets.only(left: 20),
                    //           child: Text(
                    //             "Select Games",
                    //             style: TextStyle(
                    //                 fontSize: 20, fontWeight: FontWeight.bold),
                    //           )),
                    //       IconButton(
                    //         icon: Icon(Icons.close),
                    //         onPressed: () {
                    //           Navigator.of(context).pop();
                    //         },
                    //       )
                    //     ]),
                    // Divider(),
                    // SizedBox(
                    //   height: 30,
                    // ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Form(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (games.length > 0)
                              for (var i = 0; i < games.length; i++)
                                CheckboxListTile(
                                  activeColor: Colors.green.shade400,
                                  checkColor: Colors.white,
                                  title: Text(games[i]['name']),
                                  value: values[i],
                                  onChanged: (bool? value) {
                                    setState(() {
                                      values[i] = value;
                                    });
                                  },
                                ),
                            SizedBox(
                              height: 40,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: RaisedGradientButton(
                                    child: Text(
                                      'Submit',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    gradient: LinearGradient(
                                      colors: <Color>[
                                        Colors.green.shade500,
                                        Colors.green.shade700
                                      ],
                                    ),
                                    onPressed: () {
                                      List tmp = [];
                                      int i = 0;

                                      values.forEach((element) {
                                        if (element == true) {
                                          tmp.add(games[i]['id']);
                                        }
                                        i++;
                                      });

                                      if (tmp.length > 0) {
                                        var str = tmp.join(",");

                                        Navigator.of(context).pop(str);
                                      } else {
                                        showSnackbar(context,
                                            "Please Select at least one checkbox.");
                                      }
                                      // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SelectType()));
                                    },
                                    key: Key("test"),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: RaisedGradientButton(
                                    child: Text(
                                      'Clear Filter',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    gradient: LinearGradient(
                                      colors: <Color>[
                                        Colors.red.shade600,
                                        Colors.red.shade800
                                      ],
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop("");
                                      // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SelectType()));
                                    },
                                    key: Key("test"),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ) /* add child content here */,
        ),
      ),
    );
  }
}
