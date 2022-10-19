import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:phi_collection/PC%20Supervisor/PCSupervisorDrawer.dart';
import 'package:phi_collection/utils/PCColors.dart';
import '../../Models/PendingRequest.dart';
import '../../phicollection_api.dart';
import '../../utils/PCConstants.dart';
import '../PCLogin.dart';
import 'PCSupervisorScanQR.dart';

late SharedPreferences prefs;

class PCSupervisorHomeScreen extends StatefulWidget {
  const PCSupervisorHomeScreen({super.key});

  @override
  State<PCSupervisorHomeScreen> createState() => _PCSupervisorHomeScreenState();
}

class _PCSupervisorHomeScreenState extends State<PCSupervisorHomeScreen>
with SingleTickerProviderStateMixin {


  late List<PendingRequest> pending;
  late String supervisor;

  @override
  void initState() {
    super.initState();
    setProfile();
    setSharedPrefs();
  }

  Future setSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  void logout() {
    prefs.setString('userID', "");
    prefs.setString('dtype', "");
    prefs.setString('location', "");

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const LoginScreen(),
    ));
  }

  Future setProfile() async {
    supervisor = await SessionManager().get('userID');
    pending = await getPendingRequest(supervisor);
  }

  Container card(PendingRequest payload) {
    Color cardColor;
    if(payload.status=='En Route'){
      cardColor = greenColor;
    } else if(payload.status=='Overdue'){
      cardColor = redColor;
    } else{
      cardColor = grey;
    }
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(borderRadius: radius(20), color: cardColor),
      padding: EdgeInsets.only(left: 30, top: 20),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Request Time: " '${payload.requestedAt.split("T")[1]}\n', style: const TextStyle(fontSize: 15, color: whiteColor, fontWeight: FontWeight.bold),),
            Text("Waste Type: "'${payload.waste}\n', style: const TextStyle(fontSize: 15, color: whiteColor, fontWeight: FontWeight.bold),),
            Row(
              children:[
                Text("Status: "'${payload.status}\n', style: const TextStyle(fontSize: 15, color: whiteColor, fontWeight: FontWeight.bold),),
              ]
            ),
          ]
      ),
    );
  }

  List<Container> setCards(){
    List<Container> cards = [];
    for(var request in pending){
      cards.add(card(request));
    }
    return cards;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: setProfile(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Scaffold(
              backgroundColor: whiteColor,
              body: Center(child: Image.asset("assets/images/loading.gif", color: greenColor, width: 100, height: 100,)),
            ),
          );
        } else if(snapshot.connectionState == ConnectionState.done) {
          return  Scaffold(
            drawer: const PCSupervisorDrawerComponent(),
            backgroundColor: pcBackGroundColor,
            appBar: AppBar(
              title: Text('Pending Requests'.toUpperCase(), style: boldTextStyle(size: 25, fontFamily: pcFont, color: whiteColor, weight: FontWeight.w900)),
              backgroundColor: greenColor,
              iconTheme: const IconThemeData(color: whiteColor, size: 40,),
              toolbarHeight: 100,
            ),
            body: Stack(
              children: [
                Center(
                  // child: ListView(
                  //   children: setCards(),
                  // ),
                  child: FutureBuilder(
                    future: setProfile(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                            child: Image.asset("assets/images/loading.gif", color: greenColor, width: 100, height: 100,)
                        );
                      } else if (snapshot.connectionState == ConnectionState.done) {
                        //If there are no Pending Requests in the list, show the "No Pending Requests" message
                        if(setCards().isEmpty) {
                          return Center(
                            child: Text("No Pending Requests", style: TextStyle(color: greenColor,),)
                          );
                        }
                        //otherwise display the pending requests
                        else {
                          return Center(
                            child: ListView(
                              children: setCards(),
                            ),
                          );  
                        }
                      } else {
                        return Text('State: ${snapshot.connectionState}');
                      }
                    },
                  ),
                ),

                Positioned(
                  bottom: context.height()/30,
                  right: -10,
                  child: SizedBox(
                    width: context.width()/3,
                    height: 60,
                    child: FloatingActionButton(
                      elevation: 110,
                      backgroundColor: Color.fromARGB(255, 194, 194, 194),
                      splashColor: greenColor,
                      onPressed: (){SupervisorQR().launch(context);},
                      child: Icon(FontAwesomeIcons.trashCanArrowUp, size: 45, color: greenColor,),
                      //child: const Text("Request\nCollection", style: TextStyle(color: blackColor, fontSize: 15),),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        else {
          return Text('State: ${snapshot.connectionState}');
        }
      }
    );
  }
}