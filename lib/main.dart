import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:souq_alfurat/Auth/Login.dart';
import 'package:souq_alfurat/Service/PushNotificationService.dart';
import 'package:souq_alfurat/ui/AddNewAd.dart';
import 'package:souq_alfurat/ui/AllAds.dart';
import 'package:souq_alfurat/ui/Home.dart';
import 'package:souq_alfurat/ui/SearchUi.dart';
import 'package:souq_alfurat/ui/categories/Cars&MotorCycles.dart';
import 'package:souq_alfurat/ui/categories/Clothes.dart';
import 'package:souq_alfurat/ui/categories/DevicesAndElectronics.dart';
import 'package:souq_alfurat/ui/categories/Farming.dart';
import 'package:souq_alfurat/ui/categories/Food.dart';
import 'package:souq_alfurat/ui/categories/Games.dart';
import 'package:souq_alfurat/ui/categories/Homes.dart';
import 'package:souq_alfurat/ui/categories/Livestocks.dart';
import 'package:souq_alfurat/ui/categories/Mobile.dart';
import 'package:souq_alfurat/ui/categories/OccupationsAndServices.dart';
import 'package:souq_alfurat/ui/myAccount.dart';

void setupLocator() {
  GetIt.I.registerLazySingleton(() => PushNotificationService());
}
void main() {
  setupLocator();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      //initialRoute: Home.id,
      routes: {
        SearchUi.id : (context) => SearchUi(),
        Ads.id : (context) => Ads(),
        Home.id : (context) => Home(),
        MyAccount.id : (context) => MyAccount(),
        AddNewAd.id : (context) => AddNewAd(),
        Food.id : (context) => Food(),
        Clothes.id : (context) => Clothes(),
        Games.id : (context) => Games(),
        Farming1.id : (context) => Farming1(),
        Livestock.id : (context) => Livestock(),
        Homes.id : (context) => Homes(),
        OccupationsAndServices.id : (context) => OccupationsAndServices(),
        Mobile.id : (context) => Mobile(),
        DevicesAndElectronics.id : (context) => DevicesAndElectronics(),
        CarsAndMotorCycles.id : (context) => CarsAndMotorCycles(),
      },
      home: LoginScreen(),
    )
  );
}

