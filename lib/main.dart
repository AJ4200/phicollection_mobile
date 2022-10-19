import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:phi_collection/utils/AppTheme.dart';
import 'PCLogin.dart';
import 'PCSplashScreen.dart';
import 'package:flutter_mobx/flutter_mobx.dart';


void main() {
  runApp(const MyApp());
}

//AppStore appStore = AppStore();


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => MaterialApp(
        scrollBehavior: SBehavior(),
        navigatorKey: navigatorKey,
        title: 'Phi Collection 2.0',
        debugShowCheckedModeBanner: false,
        theme: AppThemeData.lightTheme,
        darkTheme: AppThemeData.darkTheme,
        themeMode: ThemeMode.light,
        home: const PCSplashScreen(),
        // supportedLocales: LanguageDataModel.languageLocales(),
/*        localizationsDelegates: [
          AppLocalizations(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) => locale,
        locale: Locale(appStore.selectedLanguage.validate(value: AppConstant.defaultLanguage)),*/
      ),
    );

  }
}
