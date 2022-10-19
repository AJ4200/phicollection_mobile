import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:phi_collection/utils/PCConstants.dart';
import 'package:phi_collection/PC%20Driver/CommonFunctions.dart';
import '../../utils/PCColors.dart';
import '../../phicollection_api.dart';
import 'PCDriverDrawer.dart';
import 'ToGardenSite.dart';

late SharedPreferences prefs;

class PCDriverHomeScreen extends StatefulWidget {
  static const routeName = '/PCDriverHomeScreen';

  const PCDriverHomeScreen({Key? key}) : super(key: key);

  @override
  _PCDriverHomeScreenState createState() => _PCDriverHomeScreenState();

}
// ignore: must_be_immutable
class _PCDriverHomeScreenState extends State<PCDriverHomeScreen>
    with SingleTickerProviderStateMixin {

  final Completer<GoogleMapController> _controller = Completer();

  final LatLng _center = const LatLng(-26.1825, 27.9997);

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    setShared();
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('nicon');
    var initializationSettingsIOS = const IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    setUpTimedFetch();
  }

  setUpTimedFetch() async {
    Timer.periodic(const Duration(milliseconds: 5000), (timer) {
      if (request.requestNumber!=0) {
        timer.cancel();
        setState(() {
          showNotification();
        });
      } else {
        setState(() {
          getRequest();
        });
      }
    });
  }

  Future setShared() async{
    Driver = await SessionManager().get('userID');
    prefs = await SharedPreferences.getInstance();
  }

  Future getRequest() async {
    if(Driver!=""){
      request = await searchRequestFor(Driver);
    } 
  }

  Future showNotification() async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'Channel ID',
      'Requests',
      channelDescription: 'Request to fulfill',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      styleInformation: DefaultStyleInformation(true, true),
    );
    var iOSPlatformChannelSpecifics = const IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        2022,
        'New Request',
        'You have a new request to fulfill!',
        platformChannelSpecifics,
        payload: 'Default Sound'
    );
  }

  void accept() async {
    String msg = await acceptRequest(request);
    if(msg.contains('Request Accepted!')){  
      if(request.reported){
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Information"),
            content: const Text("Please Drop Off Current Bin Before Proceeding"),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    ToGS().launch(context);
                    },
                  child: const Text("OK"))
            ],
          ),
        );
      } else {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ToGS(),
        ));
      }
    }
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  List<DataRow> addRow() {
    DataRow temp;
    if (request.requestNumber != 0) {
      temp = (DataRow(cells: <DataCell>[
        DataCell(Text(request.bin)),
        DataCell(Text(request.waste)),
        //DataCell(Text(request.pickupDest.split(",")[0])),
      ]));
    } else {
      temp = (const DataRow(cells: <DataCell>[
        DataCell(Text('No')),
        DataCell(Text('Request')),
      ]));
    }
    List<DataRow> rowList = [temp];
    return rowList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const PCDriverDrawerComponent(),
      appBar: AppBar(
        title: Text('Driver Dashboard'.toUpperCase(), style: boldTextStyle(size: 25, fontFamily: pcFont, color: greenColor, weight: FontWeight.w900)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: greenColor, size: 40,),
        toolbarHeight: 100,
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          GoogleMap(
            onMapCreated: (mapController) {
              _controller.complete(mapController);
            },
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 11.0,
            ),
          ),
          Container(
            //height: context.height() / 2,
            decoration: BoxDecoration(
                color: context.scaffoldBackgroundColor, borderRadius: radiusOnly(topLeft: pcBottomSheetRadius, topRight: pcBottomSheetRadius)),
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Incoming Request:'.toUpperCase(),
                  style: boldTextStyle(
                      size: 26, fontFamily: pcFont, color: greenColor, weight: FontWeight.w900),
                ),
                25.height,
                Container(
                  //padding: EdgeInsets.only(left: 16),
                  decoration: BoxDecoration(
                    borderRadius: radius(pcButtonRadius),
                    border: Border.all(color: pcSecBorderColor),
                  ),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        DataTable(columns: const <DataColumn>[
                          DataColumn(
                            label: Text(
                              'BIN',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                                color: greenColor,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'WASTE TYPE',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                                color: greenColor,
                              ),
                            ),
                          ),
                        ], rows: addRow()),
                      ],
                    ),
                  ),
                ),
                25.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppButton(
                      //width: context.width() - 190,
                      onTap: accept,
                      color: greenColor,
                      shapeBorder: RoundedRectangleBorder(borderRadius: radius(pcButtonRadius)),
                      elevation: 5,
                      child: Text('Accept'.toUpperCase(), style: boldTextStyle(color: Colors.white)),
                    ),
                    5.width,
                    AppButton(
                      //width: context.width() - 190,
                      onTap: removeRequest,
                      color: redColor,
                      shapeBorder: RoundedRectangleBorder(borderRadius: radius(pcButtonRadius)),
                      elevation: 5,
                      child: Text('Decline'.toUpperCase(), style: boldTextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}