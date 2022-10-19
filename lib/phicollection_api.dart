import 'dart:async';
import 'dart:convert' as convert;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart' as http;
import 'package:phi_collection/Models/DriverCollections.dart';
import 'package:phi_collection/Models/PendingRequest.dart';
import 'package:phi_collection/Models/RequestCollection.dart';
import 'package:phi_collection/Models/SearchRequest.dart';
import 'package:phi_collection/Models/SupervisorRequests.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Models/Staff.dart';
import 'package:phi_collection/user_sessions';
import 'Models/Supervisor.dart';
import 'constants.dart';
import 'getHash.dart';

Future<String?> setSession(String? userid) async {
  final response = await http
      .get(Uri.parse('$baseURL/api/Procedures/MobileSessions/$userid'));

  if (response.statusCode == 200) {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var jsonResponse = json.decode(response.body);
    User testUser = User.fromJson(jsonResponse[0]);

    await SessionManager().set('userID', testUser.userid);
    await SessionManager().set('dtype', testUser.dtype);
    prefs.setString('userID', testUser.userid!);
    prefs.setString('dtype', testUser.dtype!);
    prefs.setString('email', testUser.email!);
    prefs.setString('telephone', testUser.telephone!);
    // a if statement because location can be null
    if (testUser.dtype == "Supervisor") {
      await SessionManager().set('location', testUser.location!);
      prefs.setString('location', testUser.location!);
      prefs.setString('address', testUser.address!);
    }
    if (testUser.dtype == "Driver") {
      final response = await http.post(
          Uri.parse('$baseURL/api/Procedures/Enqueue/$userid'));
      if (response.statusCode == 200) {
        debugPrint("placed in queue");
      }
    }
    return "created session";
  } else {
    if (kDebugMode) {
      print('Request failed with status: ${response.statusCode}.');
      return "fail";
    }
  }
  return null;
}

Future<Staff?> login(String? email, String? password) async {
  Staff? staff;
  String hashesPassword = getHash(password!);

  final response = await http
      .get(Uri.parse('$baseURL/api/Staffs/Login/$email/$hashesPassword'));
  debugPrint(response.body);
  if (response.statusCode == 200) {
    var jsonResponse =
        convert.jsonDecode(response.body) as Map<String, dynamic>;
    Staff testStaff = Staff.fromJson(jsonResponse);
    setSession(testStaff.staffId);
    return testStaff;
  } else {
    if (kDebugMode) {
      print('Request failed with status: ${response.statusCode}.');
    }
  }
  return null;
}

Future<bool> dequeue(String driver) async {
  final response = await http.delete(
      Uri.parse('$baseURL/api/Procedures/Dequeue/$driver'));

  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<SearchRequest> searchRequestFor(String driver) async {
  SearchRequest request = const SearchRequest(
      requestNumber: 0, bin: '', waste: '', pickupDest: '', dropoffDest: '', received: false, reported: false);
  final response = await http
      .get(Uri.parse('$baseURL/api/Procedures/SearchRequestFor/$driver'));

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    if (!jsonResponse.isEmpty) {
      request = SearchRequest.fromJson(jsonResponse[0]);
    }
  } else {
    throw Exception('Failed to load post');
  }
  return request;
}

Future<String> acceptRequest(SearchRequest request) async {
  String msg= "No Request to Accept";
  if(request.requestNumber!=0){
    final response = await http.post(Uri.parse(
        '$baseURL/api/Procedures/AcceptRequest/${request.requestNumber.toString()}'));

    if (response.statusCode == 200) {
      msg = "Request Accepted!";
    }
  }
  return msg;
}

Future<bool> arrivedAtCentral(int request) async {
  final response = await http.post(
      Uri.parse('$baseURL/api/Procedures/ArrivedAtControlStation/$request'));

  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<bool> arrivedAtLandfill(int request) async {
  final response = await http
      .post(Uri.parse('$baseURL/api/Procedures/ArrivedAtLandfill/$request'));

  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<bool> arrivedAtGardenSite(int request, String bin) async {
  final response = await http.post(
      Uri.parse('$baseURL/api/Procedures/ArrivedAtGardenSite/$request/$bin'));

  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<bool> arrivedAtReportedTruck(int request, String bin) async {
  final response = await http.post(
      Uri.parse('$baseURL/api/Procedures/ArrivedAtReportedTruck/$request/$bin'));

  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<bool> reportBreakdown(int request, String location) async {
  final response = await http.post(
      Uri.parse('$baseURL/api/Procedures/ReportTruckIssue/$request/$location'));

  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

driverProfile(String driver) async {
  DriverCollection profile = const DriverCollection(driver: '', collections: 0, breakdowns: 0,);
  final response = await http
      .get(Uri.parse('$baseURL/api/Procedures/TotalCollectionsBy/$driver'));

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    if (!jsonResponse.isEmpty) {
      final jsonResponse = json.decode(response.body);
      profile = DriverCollection.fromJson(jsonResponse[0]);
    }
  } else {
    throw Exception('Failed to load post');
  }
  return profile;
}

Future<String> requestCollection(String bin, String waste, String supervisor, String location) async {
  final response = await http.post(Uri.parse(
      '$baseURL/api/Procedures/RequestCollection/$bin/$waste/$location/$supervisor'));
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    RequestCollection requestStatus = RequestCollection.fromJson(jsonResponse[0]);
    return requestStatus.status;
  }
  return 'Failied';
}

Future<List<PendingRequest>> getPendingRequest(String supervisor) async {
  List<PendingRequest> pending = [];
  final response = await http
      .get(Uri.parse('$baseURL/api/Procedures/PendingRequestsFor/$supervisor'));

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    if (!jsonResponse.isEmpty) {
      for (var req in jsonResponse) {
        pending.add(PendingRequest.fromJson(req));
      }
    }
  } else {
    throw Exception('Failed to load post');
  }
  return pending;
}

Future<SupervisorRequest> supervisorProfile(String supervisor) async {
  SupervisorRequest profile =
      const SupervisorRequest(supervisor: '', requests: 0);
  final response = await http
      .get(Uri.parse('$baseURL/api/Procedures/TotalRequestsBy/$supervisor'));

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    if (!jsonResponse.isEmpty) {
      final jsonResponse = json.decode(response.body);
      profile = SupervisorRequest.fromJson(jsonResponse[0]);
    }
  } else {
    throw Exception('Failed to load post');
  }
  return profile;
}
