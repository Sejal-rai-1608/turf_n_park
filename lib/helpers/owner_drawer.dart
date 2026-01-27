import 'package:flutter/material.dart';
import 'package:turfandpark/owner/my_bookings_owner.dart';
import '../pages/my_profile.dart';
import '../owner/turf_list.dart';
import 'login_data.dart';
import 'helper_functions.dart';
import '../owner/parking_list.dart';
import '../pre_login_user.dart';

class OwnerAppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      // backgroundColor: Color(0xffF1F1F1),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _createHeader1(context),

          SizedBox(
            height: 20,
          ),
          _createDrawerItem(
              icon: Icons.home_outlined,
              text: 'My Turfs',
              onTap: () => {
                    Navigator.of(context).pop(),
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => OwnerTurfList()))
                  }),
          SizedBox(
            height: 10,
          ),
          _createDrawerItem(
              icon: Icons.local_parking_rounded,
              text: 'My Car Parkings',
              onTap: () => {
                    Navigator.of(context).pop(),
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ParkingListList()))
                  }),
          SizedBox(
            height: 10,
          ),
          _createDrawerItem(
              icon: Icons.local_parking_rounded,
              text: 'My profile',
              onTap: () => {
                    Navigator.of(context).pop(),
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MyProfile("owner")))
                  }),
          _createDrawerItem(
              icon: Icons.favorite_outline,
              text: 'My Bookings',
              onTap: () => {
                    Navigator.of(context).pop(),
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MyBookingsOwner()))
                  }),
          SizedBox(
            height: 10,
          ),
          _createDrawerItem(
              icon: Icons.logout,
              text: 'Logout',
              onTap: () => {onLogout(context)}),
          // ListTile(
          //   title: Text('0.0.1'),
          //   onTap: () {},
          // ),
        ],
      ),
    );
  }

  Widget _createHeader1(context) {
    return Container(
        color: Colors.green.shade500,
        child: Column(
          children: [
            SizedBox(
              height: 26,
            ),
            Container(
              padding: EdgeInsets.only(right: 2, top: 5),
              alignment: Alignment.centerRight,
              child: Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  iconSize: 22,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  // Container(
                  //   width: 90,
                  //   height: 90,
                  //   decoration: BoxDecoration(
                  //       color: Colors.grey,
                  //       image: DecorationImage(
                  //         image: NetworkImage(
                  //             "https://www.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50"),
                  //         fit: BoxFit.cover,
                  //       ),
                  //       // borderRadius: BorderRadius.all(Radius.circular(17)),
                  //       shape: BoxShape.circle),
                  // ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(Constants.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      Text("+91 " + Constants.mobile,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      Text(Constants.email,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          )),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              height: 16,
            ),
          ],
        ));
  }

  Widget _createHeader() {
    return DrawerHeader(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
            image: DecorationImage(
                scale: 0.1,
                fit: BoxFit.fill,
                image: AssetImage(
                  'assets/user-image.png',
                ))),
        child: Stack(children: <Widget>[
          Positioned(
              bottom: 12.0,
              left: 16.0,
              child: Text("Hi, " + Constants.name,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500))),
        ]));
  }

  Widget _createDrawerItem(
      {required IconData icon,
      required String text,
      required GestureTapCallback onTap}) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Container(
              padding: EdgeInsets.all(10),
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: Colors.white54),
              child: Icon(
                icon,
                color: Colors.green.shade400,
              )),
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(text),
          )
        ],
      ),
      onTap: onTap,
    );
  }

  onLogout(context) async {
    LoginData.saveTokenSharedPreference("");
    LoginData.saveUserEmailSharedPreference("");
    LoginData.saveUserLoggedInSharedPreference(false);
    LoginData.saveUserMobileSharedPreference("");
    Navigator.of(context).pop();
    Constants.isLoggedIn = false;
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => PreLoginUser()));
  }
}
