import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:phi_collection/PC%20Supervisor/PCSupervisorHomeScreen.dart';
import 'package:phi_collection/utils/PCConstants.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../phicollection_api.dart';



class SupervisorQR extends StatefulWidget {
  const SupervisorQR({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SupervisorQRState();
}

class _SupervisorQRState extends State<SupervisorQR> {

  bool buttonEnabled = true;

  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late TextEditingController _textEditingController;
  late SharedPreferences prefs;
  late String supervisor;
  late String location;
  String id = '';
  String WasteType = '';

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.

  Future<String?> enterBinIdManually() => showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Bin ID'.toUpperCase(), style: TextStyle(color: greenColor),),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(hintText: 'Enter Bin ID'.toUpperCase()),
          controller: _textEditingController,
          //keyboardType: TextInputType.number,

        ),
        actions: [
          TextButton(
            //onPressed: continueToLand,
            onPressed: submit,
            child: Text(
              'SUBMIT & CONTINUE'.toUpperCase(),
              style: TextStyle(
                color: greenColor,
              ),
            ),
          ),
        ],
      )
  );

  void submit() {
    Navigator.of(context).pop(_textEditingController.text);
    _textEditingController.clear();
    wasteTypePrompt();
  }

  void supToDash(String wasteType) async {
    String sent = await requestCollection(id, wasteType, supervisor, location);
    if (sent == "Success") {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Confirmation"),
          content: const Text("Your request has been Submitted"),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  PCSupervisorHomeScreen().launch(context);
                  },
                child: const Text("OK"))
          ],
        ),
      );
    }
    else if (sent == "Duplicate") {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Information"),
          content: const Text("Request Already Exists"),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  PCSupervisorHomeScreen().launch(context);
                  },
                child: const Text("OK"))
          ],
        ),
      );
    }
    else if (sent == "Invalid Bin") {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Information"),
          content: const Text("Bin Not In Garden Site"),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  PCSupervisorHomeScreen().launch(context);
                  },
                child: const Text("OK"))
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _textEditingController  = TextEditingController();
    setSharedPrefs();
  }

  Future setSharedPrefs() async {
    supervisor = await SessionManager().get('userID');
    location = await SessionManager().get('location');
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text("Scan the Bin's QR Code".toUpperCase(), style: TextStyle(color: greenColor, fontWeight: FontWeight.bold),),
        backgroundColor: whiteColor,
      ),
      body: Column(
        children: <Widget>[
          Expanded(flex: 3, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  5.height,
                  if (result != null)
                    AppButton(
                      //enabled: false,
                      //button is enable once qr code is scanned
                      //disabledColor: lightGreen,
                      child: Text('Scanned, Continue'.toUpperCase(), style: boldTextStyle(color: Colors.white), ),
                      onTap: () {
                        setState(() => this.id = result!.code!);
                        wasteTypePrompt();
                      },
                      color: greenColor,
                      shapeBorder: RoundedRectangleBorder(borderRadius: radius(pcButtonRadius)),
                      elevation: 0,
                    )
                  else
                    AppButton(
                      child: Text('Enter ID Manually'.toUpperCase(), style: boldTextStyle(color: Colors.white), ),
                      onTap: () async {
                        final id = await enterBinIdManually();
                        if(id == null || id.isEmpty) return;
                        setState(() => this.id = id);
                      },
                      color: greenColor,
                      shapeBorder: RoundedRectangleBorder(borderRadius: radius(pcButtonRadius)),
                      elevation: 0,
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child:
                        ElevatedButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(EdgeInsets.all(6)),
                            backgroundColor: MaterialStateProperty.all(greenColor),
                          ),
                          onPressed: () async {
                            await controller?.flipCamera();
                            setState(() {});
                          },
                          child: FutureBuilder(
                            future: controller?.getCameraInfo(),
                            builder: (context, snapshot) {
                              if (snapshot.data != null) {
                                return const Icon(Icons.camera_alt, color: whiteColor,);
                              } else {
                                return const Text('loading');
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  wasteTypePrompt() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          "Choose Waste Type To Continue",
          style: TextStyle(
            color: Colors.black,
            fontSize: 15,
          ),
        ),
        actions: <Widget>[
          ListBody(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  supToDash("Plastic");
                },
                icon: const Icon(FontAwesomeIcons.bagShopping, color: Colors.black,),
                label: const Text("Plastic", style: TextStyle(color: Colors.black),),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  supToDash("Industrial Waste");
                },
                icon: const Icon(Icons.factory_rounded, color: Colors.black,),
                label: const Text("Industrial Waste", style: TextStyle(color: Colors.black),),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  supToDash("Cardboard and Paper");
                },
                icon: const Icon(FontAwesomeIcons.book, color: Colors.black,),
                label: const Text("Cardboard and Paper", style: TextStyle(color: Colors.black),),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  supToDash("Glass");
                },
                icon: const Icon(Icons.wine_bar, color: Colors.black,),
                label: const Text("Glass", style: TextStyle(color: Colors.black),),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  supToDash("Garden Waste");
                },
                icon: const Icon(FontAwesomeIcons.leaf, color: Colors.black,),
                label: const Text("Garden Waste", style: TextStyle(color: Colors.black),),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  supToDash("General Waste");
                },
                icon: const Icon(FontAwesomeIcons.trash, color: Colors.black,),
                label: const Text("General Waste", style: TextStyle(color: Colors.black),),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 250.0 //Change the size of the QRView
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.green,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
      ///camera starts
      controller.resumeCamera();
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        if(result != null){
          controller.stopCamera(); ///camera stops once code scanned
          wasteTypePrompt();
          //controller.flipCamera();
        }
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    _textEditingController.dispose();
    super.dispose();
  }
}
