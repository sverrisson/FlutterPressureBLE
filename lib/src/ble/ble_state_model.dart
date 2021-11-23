import 'package:flutter/cupertino.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:simple_logger/simple_logger.dart';

enum BleStatus { unknown, scanning, idle, unavailable }

class BleStateModel extends ChangeNotifier {
  /// Internal, private state
  List<ScanResult> _devices = [];
  int? _index;
  BleStatus _status = BleStatus.unknown;
  final simpleLogger = SimpleLogger();

  FlutterBlue bleManager = FlutterBlue.instance;
  static final List<Guid> findServiceUuids = [
    Guid("7E4148A0-AB23-4DC2-A36F-471884A30548")
  ];

  /// List of scanned devices
  List<ScanResult> get devices => _devices;

  /// Current selected device.
  int? get selected => _index;

  /// Current status.
  BleStatus get status => _status;

  /// Scans for available peripherals
  void scan({List<Guid> serviceUuids = const []}) {
    if (_devices.isNotEmpty) {
      removeAll();
    }
    _status = BleStatus.scanning;
    bleManager.startScan(
      withServices: serviceUuids,
      timeout: const Duration(seconds: 5),
    );
    simpleLogger.info("☢️ StartScan");

    bleManager.scanResults.listen((results) {
      _devices = results;
      simpleLogger.info("☢️ Found ${results.length} devices");
      notifyListeners();
    });
  }

  void selectDevice(ScanResult device) {
    //TODO: Find index
    _index = 0;
    stop();
    _status = BleStatus.idle;
  }

  /// Removes all items from the cart.
  void stop() {
    if (_status == BleStatus.scanning) {
      simpleLogger.info("☢️ Stoop Scanning");
      bleManager.stopScan();
      _status = BleStatus.idle;
    }
  }

  /// Removes all items from the cart.
  void removeAll() {
    stop();
    simpleLogger.info("☢️ Clear Devices");
    _index = null;
    _devices.clear();
    _status = BleStatus.unknown;
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }
}
