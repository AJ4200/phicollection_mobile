import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:phi_collection/Models/SearchRequest.dart';
import 'package:phi_collection/phicollection_api.dart';
import 'PCDriverHomeScreen.dart';

SearchRequest request = const
    SearchRequest(requestNumber: 0, bin: '', waste: '' , pickupDest: '', dropoffDest: '', received: false, reported: false);

String Driver = '';

Future<bool> reportEmergency(String emergemcyLocation) async {
  bool reported = await reportBreakdown(request.requestNumber, emergemcyLocation);
  if (reported) {
    removeRequest();
  }
  return reported;
}

void removeRequest(){
  request = const SearchRequest(requestNumber: 0, bin: '', waste: '', pickupDest: '', dropoffDest: '', received: false, reported: false);
}