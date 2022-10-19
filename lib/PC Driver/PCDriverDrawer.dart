import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:phi_collection/PC%20Driver/CommonFunctions.dart';
import 'package:phi_collection/phicollection_api.dart';
import '../../utils/PCColors.dart';
import '../PCLogin.dart';
import 'PCDriverProfileScreen.dart';
import 'PCDriverHomeScreen.dart';

//late SharedPreferences prefs;

class PCDriverDrawerComponent extends StatefulWidget {
  const PCDriverDrawerComponent({Key? key}) : super(key: key);

  @override
  State<PCDriverDrawerComponent> createState() => _PCDriverDrawerComponentState();
}

class _PCDriverDrawerComponentState extends State<PCDriverDrawerComponent> {

  Future<void> logout() async {
    await dequeue(Driver);

    prefs.clear();
    SessionManager().destroy();
    removeRequest();
    Driver = '';

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => LoginScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: greenColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: whiteColor),
                    borderRadius: radius(100),
                  ),
                  child: Icon(
                    Icons.person,
                    color: blackColor,
                    size: 50,
                  ).cornerRadiusWithClipRRect(100),
                ),
                25.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      //PCDriverProfileScreen().launch(context);
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            finish(context);
                            PCDriverProfileScreen().launch(context);
                          },
                          style: TextButton.styleFrom(backgroundColor: whiteColor,),
                          child: Text('User Profile'.toUpperCase(), style: boldTextStyle(color: greenColor, wordSpacing: 5)),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 25),
                      onPressed: () {
                        finish(context);
                        PCDriverProfileScreen().launch(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          ///This is the empty expanded space in the drawer
          Expanded(
            child: Text("a", style: TextStyle(color: whiteColor),),
          ),
          Divider(
            height: 5,
            color: greenColor,
          ),
          ListTile(
            minLeadingWidth: 0,
            title: Text("Log Out", style: boldTextStyle()),
            trailing: Icon(Icons.logout, color: blackColor,),
            onTap: confirmLogout,
          ),
        ],
      ),
    );
  }

  confirmLogout() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Warning"),
        content: const Text("Are you sure you want to logout?"),
        actions: <Widget>[
          TextButton(
            onPressed: logout,
            child: const Text(
              "Yes",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              "No",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
