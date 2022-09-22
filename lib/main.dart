import 'package:billing/models/company.dart';
import 'package:billing/providers/db_provider.dart';
import 'package:billing/providers/screen_provider.dart';

import 'package:billing/screens/main_home.dart';
import 'package:billing/util/injector.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:billing/providers/app_provider.dart';

import 'package:billing/util/const.dart';

import 'util/const.dart';

void main() {
  setupLocator();
  runApp(
    // MultiProvider(
    //   providers: [

    //     //ChangeNotifierProvider(create: (_) => DbProvider()),
    //   ],
    //  child:
    MyApp(),
    //),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppProvider()),
          ChangeNotifierProvider(create: (_) => ScreenProvider()),
          StreamProvider<Company>(
              create: (_) => DbProvider(company: 'company').companyData),
          // StreamProvider<List<ProductItem>>(
          //     create: (_) => DbProvider(company: 'company').productData),
        ],
        child: Consumer<AppProvider>(
          builder:
              (BuildContext context, AppProvider appProvider, Widget child) {
            return MaterialApp(
              key: appProvider.key,
              debugShowCheckedModeBanner: false,
              navigatorKey: appProvider.navigatorKey,
              title: Constants.appName,
              theme: appProvider.theme,
              darkTheme: Constants.darkTheme,
              //home: SplashScreen(),
              home: MainHome(),
            );
          },
        ));
  }
}
