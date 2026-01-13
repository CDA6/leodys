import 'package:internet_connection_checker/internet_connection_checker.dart';

class InternetUtil
{
  static Future<bool> hasInternetAccess() async
  {
    return InternetConnectionChecker.instance.hasConnection;
  }
}