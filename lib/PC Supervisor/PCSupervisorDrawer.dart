import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:nb_utils/nb_utils.dart';
import '../PCLogin.dart';
import 'PCSupervisorProfileScreen.dart';
import 'PCSupervisorHomeScreen.dart';

//late SharedPreferences prefs;

class PCSupervisorDrawerComponent extends StatefulWidget {
  const PCSupervisorDrawerComponent({Key? key}) : super(key: key);

  @override
  State<PCSupervisorDrawerComponent> createState() => _PCSupervisorDrawerComponentState();
}

class _PCSupervisorDrawerComponentState extends State<PCSupervisorDrawerComponent> {

  void logout() {
    prefs.clear();
    SessionManager().destroy();

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
//                  child: Icon(FontAwesomeIcons.d),
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: blackColor,
                  ).cornerRadiusWithClipRRect(100),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: radius(100),
                  ),
                ),
                16.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            finish(context);
                            PCSupervisorProfileScreen().launch(context);
                          },
                          style: TextButton.styleFrom(backgroundColor: whiteColor,),
                          child: Text('User Profile'.toUpperCase(), style: boldTextStyle(color: greenColor, wordSpacing: 5)),
                        ),
                      ],
                    ),
                    //style: boldTextStyle(color: Colors.white, size: 18)
                    IconButton(
                      icon: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 25),
                      onPressed: () {
                        finish(context);
                        PCSupervisorProfileScreen().launch(context);
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
            trailing: Icon(Icons.logout, color: Colors.black,),
            onTap: logout,
          ),
        ],
      ),
    );
  }
}
