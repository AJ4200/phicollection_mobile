import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:nb_utils/nb_utils.dart';
import 'package:phi_collection/PC%20Driver/CommonFunctions.dart';
import '../../constants.dart';
import '../../phicollection_api.dart';
import '../../utils/PCColors.dart';
import '../../utils/PCConstants.dart';
import 'PCDriverHomeScreen.dart';

class ToCentral extends StatefulWidget {
  @override
  _ToCentralState createState() => _ToCentralState();
}

class _ToCentralState extends State<ToCentral> {
  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
  late GoogleMapController mapController;

  String issueType = '';

  late Position _currentPosition;
  //final String _destinationPosition = "Campus Square";
  String _currentAddress = '';

  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  final startAddressFocusNode = FocusNode();
  final desrinationAddressFocusNode = FocusNode();

  String _startAddress = '';
  ///Here we add the destination address and it works wonders
  final String _destinationAddress = 'Pikitup Randburg Depot, Malibongwe Drive, Praegville, Randburg, South Africa';
  String? _placeDistance;

  Set<Marker> markers = {};

  late PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Method for retrieving the current location
  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
        print('CURRENT POS: $_currentPosition');
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });
      await _getAddress();
    }).catchError((e) {
      print(e);
    });
  }

  // Method for retrieving the address
  _getAddress() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
        "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
        startAddressController.text = _currentAddress;
        _startAddress = _currentAddress;
      });
    } catch (e) {
      print(e);
    }
  }

  // Method for calculating the distance between two places
  Future<bool> _calculateDistance() async {
    try {
      // Retrieving placemarks from addresses
      List<Location> startPlacemark = await locationFromAddress(_startAddress);
      List<Location> destinationPlacemark =
      await locationFromAddress(_destinationAddress);

      // Use the retrieved coordinates of the current position,
      // instead of the address if the start position is user's
      // current position, as it results in better accuracy.
      double startLatitude = _startAddress == _currentAddress
          ? _currentPosition.latitude
          : startPlacemark[0].latitude;

      double startLongitude = _startAddress == _currentAddress
          ? _currentPosition.longitude
          : startPlacemark[0].longitude;

      double destinationLatitude = destinationPlacemark[0].latitude;
      double destinationLongitude = destinationPlacemark[0].longitude;

      String startCoordinatesString = '($startLatitude, $startLongitude)';
      String destinationCoordinatesString =
          '($destinationLatitude, $destinationLongitude)';

      // Start Location Marker
      Marker startMarker = Marker(
        markerId: MarkerId(startCoordinatesString),
        position: LatLng(startLatitude, startLongitude),
        infoWindow: InfoWindow(
          title: 'Start $startCoordinatesString',
          snippet: _startAddress,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      // Destination Location Marker
      Marker destinationMarker = Marker(
        markerId: MarkerId(destinationCoordinatesString),
        position: LatLng(destinationLatitude, destinationLongitude),
        infoWindow: InfoWindow(
          title: 'Destination $destinationCoordinatesString',
          snippet: _destinationAddress,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(120),
      );

      // Adding the markers to the list
      markers.add(startMarker);
      markers.add(destinationMarker);

      print(
        'START COORDINATES: ($startLatitude, $startLongitude)',
      );
      print(
        'DESTINATION COORDINATES: ($destinationLatitude, $destinationLongitude)',
      );

      // Calculating to check that the position relative
      // to the frame, and pan & zoom the camera accordingly.
      double miny = (startLatitude <= destinationLatitude)
          ? startLatitude
          : destinationLatitude;
      double minx = (startLongitude <= destinationLongitude)
          ? startLongitude
          : destinationLongitude;
      double maxy = (startLatitude <= destinationLatitude)
          ? destinationLatitude
          : startLatitude;
      double maxx = (startLongitude <= destinationLongitude)
          ? destinationLongitude
          : startLongitude;

      double southWestLatitude = miny;
      double southWestLongitude = minx;

      double northEastLatitude = maxy;
      double northEastLongitude = maxx;

      /// Accommodate the two locations within the
      /// camera view of the map
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            northeast: LatLng(northEastLatitude, northEastLongitude),
            southwest: LatLng(southWestLatitude, southWestLongitude),
          ),
          10.0,
        ),
      );

      // Calculating the distance between the start and the end positions
      // with a straight path, without considering any route
      // double distanceInMeters = await Geolocator.bearingBetween(
      //   startLatitude,
      //   startLongitude,
      //   destinationLatitude,
      //   destinationLongitude,
      // );

      await _createPolylines(startLatitude, startLongitude, destinationLatitude,
          destinationLongitude);

      double totalDistance = 0.0;

      // Calculating the total distance by adding the distance
      // between small segments
      for (int i = 0; i < polylineCoordinates.length - 1; i++) {
        totalDistance += _coordinateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude,
        );
      }

      setState(() {
        _placeDistance = totalDistance.toStringAsFixed(2);
        print('DISTANCE: $_placeDistance km');
      });

      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  // Formula for calculating distance between two coordinates
  // https://stackoverflow.com/a/54138876/11910277
  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // Create the polylines for showing the route between two places
  _createPolylines(
      double startLatitude,
      double startLongitude,
      double destinationLatitude,
      double destinationLongitude,
      ) async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key, // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.transit,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: greenColor,
      points: polylineCoordinates,
      width: 4,
    );
    polylines[id] = polyline;
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _calculateDistance();

  }

  void arrivedAtCent() async {
    bool arrived = await arrivedAtCentral(request.requestNumber);
    if (arrived) {
      removeRequest();
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const PCDriverHomeScreen(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      height: height,
      width: width,
      child: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            /// Map View
            GoogleMap(
              markers: Set<Marker>.from(markers),
              initialCameraPosition: _initialLocation,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              polylines: Set<Polyline>.of(polylines.values),
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
            ),
            Positioned(
              bottom: 0,
              width: context.width(),
              child: Container(
                decoration: BoxDecoration(
                  //color: context.scaffoldBackgroundColor,
                    color: Colors.transparent,
                    borderRadius: radiusOnly(topLeft: pcBottomSheetRadius, topRight: pcBottomSheetRadius)),
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppButton(
                      width: context.width() - 32,
                      child: Text('Confirm Arrival'.toUpperCase(), style: boldTextStyle(color: Colors.white), ),
                      onTap: () {
                        confirmArrival();
                      },
                      color: greenColor,
                      shapeBorder: RoundedRectangleBorder(borderRadius: radius(pcButtonRadius)),
                      elevation: 5,
                    ),
                    10.height,
                    AppButton(
                      width: context.width() - 32,
                      child: Text('Report'.toUpperCase(), style: boldTextStyle(color: Colors.white)),
                      onTap: reportTruckBreakdownPrompt,
                      color: pcPrimaryColor,
                      shapeBorder: RoundedRectangleBorder(borderRadius: radius(pcButtonRadius)),
                      elevation: 5,
                    ),
                  ],
                ),
              ),
            ),
            /// Show zoom buttons
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ClipOval(
                      child: Material(
                        color: greenColor, // button color
                        child: InkWell(
                          splashColor: Colors.white, // inkwell color
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: Icon(Icons.add, color: Colors.white, size: 30,),
                          ),
                          onTap: () {
                            mapController.animateCamera(
                              CameraUpdate.zoomIn(),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ClipOval(
                      child: Material(
                        color: greenColor, // button color
                        child: InkWell(
                          splashColor: Colors.white, // inkwell color
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: Icon(Icons.remove, color: Colors.white, size: 30,),
                          ),
                          onTap: () {
                            mapController.animateCamera(
                              CameraUpdate.zoomOut(),
                            );
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            /// Show the place input fields & button for
            /// showing the route
            Positioned(
              top: 0,
              width: context.width(),
              child: SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        //color: Colors.transparent,
                        color: Colors.white70,
                        borderRadius: BorderRadius.all(
                          Radius.circular(20.0),
                        ),
                      ),
                      width: width * 0.9,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'To Central'.toUpperCase(),
                              style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w900, color: greenColor),
                            ),
                            5.height,
                            Visibility(
                              visible: _placeDistance == null ? false : true,
                              child: Text(
                                'DISTANCE: $_placeDistance km',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            5.height,
                            ElevatedButton(
                              onPressed: (_startAddress != '' &&
                                  _destinationAddress != '')
                                  ? () async {
                                startAddressFocusNode.unfocus();
                                desrinationAddressFocusNode.unfocus();
                                setState(() {
                                  if (markers.isEmpty) markers.addAll(markers);
                                  if (polylines.isNotEmpty)
                                    polylines.clear();
                                  if (polylineCoordinates.isNotEmpty)
                                    polylineCoordinates.clear();
                                  _placeDistance = null;
                                });

                                _calculateDistance().then((isCalculated) {
                                  if (isCalculated) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Distance Calculated Successfully'),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Error Calculating Distance'),
                                      ),
                                    );
                                  }
                                });
                              }
                                  : null,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Start Navigation'.toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                  ),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: greenColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            /// Show current location button
            SafeArea(
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: ClipOval(
                    child: Material(
                      color: greenColor, // button color
                      child: InkWell(
                        splashColor: Colors.white, // inkwell color
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Icon(Icons.my_location, color: Colors.white, size: 30,),
                        ),
                        onTap: () {
                          mapController.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(
                                  _currentPosition.latitude,
                                  _currentPosition.longitude,
                                ),
                                zoom: 18.0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  confirmArrival() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Arrival"),
        content: const Text("Have you arrived at the Central Site?"),
        actions: <Widget>[
          TextButton(
            onPressed: arrivedAtCent,
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

  reportTruckBreakdownPrompt() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          "Report",
          style: TextStyle(
            color: Colors.black,
            fontSize: 15,
          ),
        ),
        actions: <Widget>[
          ListBody(
            children: [
              ElevatedButton(
                onPressed: reportIssue,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(pcPrimaryColor),
                ),
                child: const Text("Breakdown", style: TextStyle(color: Colors.black),),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void reportIssue() async {
    bool reported = await reportEmergency(_currentAddress);
    if (reported) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Confirmation"),
          content: const Text("Your report has been submitted"),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  const PCDriverHomeScreen().launch(context);
                },
                child: const Text("OK"))
          ],
        ),
      );
    }
  }

}

