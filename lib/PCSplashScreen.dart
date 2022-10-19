import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'utils/PCColors.dart';
import 'utils/PCConstants.dart';
import 'PCLogin.dart';


class PCSplashScreen extends StatefulWidget {
  const PCSplashScreen({Key? key}) : super(key: key);

  @override
  State<PCSplashScreen> createState() => _PCSplashScreenState();
}

class _PCSplashScreenState extends State<PCSplashScreen> {
  @override
  void initState() {
    super.initState();
    //
    init();
  }

  Future<void> init() async {
    setStatusBarColor(Colors.transparent);
    await 3.seconds.delay;
    LoginScreen().launch(context,isNewTask: true);
  }

  @override
  void dispose() {
    super.dispose();
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
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // SizedBox(height: context.statusBarHeight + 50),
                SizedBox(
                  height: context.height() / 2,
                  child: Image.asset('assets/images/android/phi_logo.png', height: 300, width: 300, fit: BoxFit.contain),
                ),
                SizedBox(
                  height: context.height() / 2,
                  child: Image.asset('assets/images/loading.gif', color: greenColor, width: 80, height: 80),
                ),
                //Image.asset('assets/images/android/phi_logo.png', height: 180, width: 180, fit: BoxFit.cover),
                //50.height,
                //Text('Phi Collection', style: boldTextStyle(size: 50, fontFamily: pcFont, color: pcDarkColor, weight: FontWeight.w900)),
                //Image.asset('assets/images/loading.gif', color: blackColor, width: 80, height: 80),
              ],
            ),
            // Positioned(
            //   bottom: 0,
            //   child: Image.asset('images/juberCarBooking/jcb_splash_background_image.png', width: context.width(), fit: BoxFit.cover),
            // ),
            // Image.asset('assets/images/loading.gif', color: pcDarkColor, width: 80, height: 80),
          ],
        ),
      ),
    );
  }
}
