import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../Models/SupervisorRequests.dart';
import '../../phicollection_api.dart';
import '../../utils/PCColors.dart';
import '../../utils/PCConstants.dart';

class PCSupervisorProfileScreen extends StatefulWidget {
  @override
  State<PCSupervisorProfileScreen> createState() => _PCSupervisorProfileScreenState();
}

class _PCSupervisorProfileScreenState extends State<PCSupervisorProfileScreen> {
  late SupervisorRequest profile;
  late String supervisor;
  late String address;
  late String email;
  late String telephone;

  @override
  void initState() {
    super.initState();
    setProfile();
  }

  Future setProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    address = prefs.getString("address")!;
    email = prefs.getString("email")!;
    telephone= prefs.getString("telephone")!;
    supervisor = await SessionManager().get('userID');
    profile = await supervisorProfile(supervisor);
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: setProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: Image.asset("assets/images/loading.gif", color: greenColor, width: 100, height: 100,)
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            backgroundColor: whiteColor,
            appBar: AppBar(
              toolbarHeight: 150,
              backgroundColor: greenColor,
              leading: IconButton(
                icon: Image.asset(
                  "assets/images/Icons/ic_close.png",
                  height: 20,
                  width: 20,
                  fit: BoxFit.cover,
                  color: whiteColor,
                ),
                onPressed: () {
                  finish(context);
                },
              ),
              title: Text(
                "Supervisor Profile", style: TextStyle(color: whiteColor, fontSize: 30, fontWeight: fontWeightBoldGlobal),
              ),
              elevation: 0,
            ),
            body: FutureBuilder(
              future: setProfile(),
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Image.asset('assets/images/loading.gif', color: greenColor, width: 80, height: 80),
                  );
                }
                else if(snapshot.connectionState == ConnectionState.done) {
                  return ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      buildProfile()
                    ],
                  );
                }
                else {
                  return Text('State: ${snapshot.connectionState}');
                }
              },
            ),
          );
        } else {
          return Text('State: ${snapshot.connectionState}');
        }
      }
    );
  }

  Widget buildProfile() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hey \n'+profile.supervisor +'!',
                style: boldTextStyle(
                    size: 30, fontFamily: pcFont, color: greenColor, weight: FontWeight.w900),
              ),
            ],
          ),
          20.height,
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(border: Border.all(color: pcSecBorderColor), borderRadius: radius(pcButtonRadius)),
            width: context.width() - 32,
            child: Column(
              children: [
                Row(
                  children: [
                    Text('EMAIL:'.toUpperCase(), style: boldTextStyle(color: greenColor)),
                    Text(email),
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
                10.height,
              ],
            ),
          ),
          16.height,
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(border: Border.all(color: pcSecBorderColor), borderRadius: radius(pcButtonRadius)),
            width: context.width() - 32,
            child: Column(
              children: [
                Row(
                  children: [
                    Text('PHONE NUMBER:'.toUpperCase(), style: boldTextStyle(color: greenColor)),
                    Text(telephone),
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
                10.height,
              ],
            ),
          ),
          16.height,
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(border: Border.all(color: pcSecBorderColor), borderRadius: radius(pcButtonRadius)),
            width: context.width() - 32,
            child: Column(
              children: [
                Row(
                  children: [
                    Text('No. of Requests Made:'.toUpperCase(), style: boldTextStyle(color: greenColor)),
                    Text(profile.requests.toString()),
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
                10.height,
              ],
            ),
          ),
          16.height,
        ],
      ),
    );
  }
}
