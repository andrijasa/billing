import 'getit.dart';

import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  // Register LoginService as Singleton
  locator.registerSingleton(SaleItemPdf());

  // Register UserProfile as Factory
  //locator.registerFactory(() => UserProfile());
}