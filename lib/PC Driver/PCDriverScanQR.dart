import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:phi_collection/PC%20Driver/CommonFunctions.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../main.dart';
import '../../phicollection_api.dart';
import '../../utils/PCConstants.dart';
import 'ToLF.dart';
import 'PCDriverHomeScreen.dart';

class DriverQR extends StatefulWidget {
  const DriverQR({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DriverQRState();
}

class _DriverQRState extends State<DriverQR> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  late TextEditingController _textEditingController;
  String id = '';

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.

  Future<String?> enterBinIdManually() => showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Bin ID'.toUpperCase(), style: TextStyle(color: greenColor,),),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(hintText: 'Enter Bin ID'.toUpperCase(),),
          controller: _textEditingController,
          //keyboardType: TextInputType.number,

        ),
        actions: [
          TextButton(
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
  }

  @override
  void initState() {
    super.initState();
    _textEditingController  = TextEditingController();
  }

  void continueToLand() async {
    if(id!=request.bin){
      Fluttertoast.showToast(
        msg: 'Incorrect Bin\nCollect ${request.bin}',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        textColor: Colors.white,
        fontSize: 16.0
      );
    } else {
      bool arrived;
      if(request.reported){
        arrived = await arrivedAtGardenSite(request.requestNumber, id);
      } else {
        arrived = await arrivedAtReportedTruck(request.requestNumber, id);
      }
      if (arrived) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ToLF(),
        ));
      }
    }
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
                      disabledColor: lightGreen,
                      //width: context.width() - 32,
                      child: Text('Code Scanned, Continue'.toUpperCase(), style: boldTextStyle(color: Colors.white), ),
                      onTap: () {
                        setState(() => this.id = result!.code!);
                        continueToLand();
                      },
                      color: greenColor,
                      shapeBorder: RoundedRectangleBorder(borderRadius: radius(pcButtonRadius)),
                      elevation: 0,
                    )
                  else
                    AppButton(
                      //width: context.width() - 32,
                      child: Text('Enter ID Manually'.toUpperCase(), style: boldTextStyle(color: Colors.white), ),
                      onTap: () async {
                        final id = await enterBinIdManually();
                        if(id == null || id.isEmpty) return;
                        setState(() => this.id = id);
                        continueToLand();
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

  scannedQR() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          "Code Scanned, Successfully",
          style: TextStyle(
            color: Colors.black,
            fontSize: 15,
          ),
        ),
        actions: <Widget>[
          ListBody(
            children: [
              TextButton(
                  onPressed: () {
                    setState(() => this.id = result!.code!);
                    continueToLand();
                  },
                  child: const Text("CONTINUE"))
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
          scannedQR();
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