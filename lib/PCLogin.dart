import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:phi_collection/PC%20Driver/ToCentral.dart';
import 'package:phi_collection/PC%20Supervisor/PCSupervisorHomeScreen.dart';
import 'Models/Staff.dart';
import 'PC Driver/PCDriverHomeScreen.dart';
import 'phicollection_api.dart';
import 'utils/PCColors.dart';
import 'utils/PCConstants.dart';

Staff? staff;
var isLoggedIn = false;

class RouteGenerator {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/PCDriverHomeScreen':
        return MaterialPageRoute(builder: (_) => PCDriverHomeScreen());
      case '/PCSupervisorHomeScreen':
        return MaterialPageRoute(builder: (_) => PCSupervisorHomeScreen());
      case '/LoginScreen':
        return MaterialPageRoute(builder: (_) => LoginScreen());
    }
  }
}

class LoginScreen extends StatefulWidget {
  static String routeName = '/auth';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AutoLogin();
}

class _AutoLogin extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    autoLogIn();
  }

  void autoLogIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('UserID');
    final String? dtype = prefs.getString('dtype');
    if (userId != "") {
      switch (dtype) {
        case 'Driver':
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=> PCDriverHomeScreen()));
          break;
        case 'Supervisor':
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=> PCSupervisorHomeScreen()));
          break;
      }
    }
  }

  Duration get loginTime => const Duration(milliseconds: 2250);

  Future<String?> _authUser(LoginData data) async {
    return Future.delayed(loginTime).then((_) async {
      staff = await login(data.name, data.password);
      if (staff == null) {
        return 'incorrect username or password';
      }
    });
  }

  Future<String> _recoverPassword(String name) {
    debugPrint('Name: $name');
    return Future.delayed(loginTime).then((_) {
      if (staff?.name == name) {
        return 'User not exists';
      }
      return 'null';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: SizedBox(
        height: context.height(),
        width: context.width(),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ///login card
            FlutterLogin(
                //title: 'User Login'.toUpperCase(),
                logo: "assets/images/android/phi_logo.png",
                onLogin: _authUser,
                hideForgotPasswordButton: true,
                hideProvidersTitle: true,
                showDebugButtons: false,
                theme: LoginTheme(
                    primaryColor: whiteColor,
                    accentColor: greenColor,
                    errorColor: Colors.red,
                    cardTheme: const CardTheme(color: Color.fromARGB(255, 194, 194, 194)),
                    buttonTheme: const LoginButtonTheme(
                      backgroundColor: greenColor,
                      highlightColor: lightGreen,
                    ),
                    logoWidth: 1.5),
                onSubmitAnimationCompleted: () {
                  switch (staff?.dtype.toString()) {
                    case 'Driver':
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=> PCDriverHomeScreen()));
                      break;
                    case 'Supervisor':
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=> PCSupervisorHomeScreen()));
                      break;
                  }
                },
                onRecoverPassword: _recoverPassword,

              ///Temporary Buttons for navigation
              /*children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=> PCSupervisorHomeScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("Supervisor Dashboard"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=> PCDriverHomeScreen()));
                  },
                  child: const Text("Driver"),
                )
              ],*/

            ),
            ///Logo
            // Positioned(
            //   top: context.statusBarHeight / 1,
            //   child: Image.asset('assets/images/android/phi_logo.png', height: 180, width: 180, fit: BoxFit.cover),
            // ),
            ///Title
            // Positioned(
            //   top: context.height()/8,
            //   child: Text('Phi Collection', style: boldTextStyle(size: 50, fontFamily: pcFont, color: greenColor, weight: FontWeight.w900)),
            // ),
          ],
        ),
      ),
    );
  }
}
