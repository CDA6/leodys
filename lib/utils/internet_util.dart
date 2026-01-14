import 'dart:async';
import 'package:leodys/utils/app_logger.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class InternetUtil
{
  //Stream to listen
  static final StreamController<InternetConnectionStatus> _statusController =
  StreamController<InternetConnectionStatus>.broadcast();

  static InternetConnectionStatus? _lastKnownStatus;

  static InternetConnectionStatus? get lastKnownStatus => _lastKnownStatus;
  static bool get isConnected => _lastKnownStatus == InternetConnectionStatus.connected;

  //access to the stream to bind another object from outside
  static Stream<InternetConnectionStatus> get onStatusChange => _statusController.stream;

  //need to be called once only
  static Future<void> init() async
  {
    _lastKnownStatus = await InternetConnectionChecker.instance.connectionStatus;
    AppLogger().info("Initial connection status detected : $_lastKnownStatus");
    if (_lastKnownStatus != null) {
      _statusController.add(_lastKnownStatus!);
    }

    InternetConnectionChecker.instance.onStatusChange.listen((status){
      AppLogger().info("Connexion status changed to : $status");
      _lastKnownStatus = status;
      _statusController.add(status);
    });

    AppLogger().info("End Internet util initialisation");
  }
}