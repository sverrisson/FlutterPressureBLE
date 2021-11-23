import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue/flutter_blue.dart';

// BleManager is a singleton
class xBleManager with ChangeNotifier {
  static xBleManager? _instance;
  xBleManager._();
  static xBleManager get instance => _instance ??= xBleManager._();

  FlutterBlue ble = FlutterBlue.instance;
  final BluetoothState? state = BluetoothState.unknown;
  List<ScanResult> peripherals = [];
  List<Guid> serviceUuids = [Guid("7E4148A0-AB23-4DC2-A36F-471884A30548")];

  // Future<List<ScanResult>> scanDevices() async {
  //   // Start scanning
  //   List<ScanResult> newPeripherals = [];

  //   ble.startScan(
  //       // withServices: serviceUuids,
  //       timeout: const Duration(seconds: 3));
  //   print("StartScan");

  //   ble.scanResults.listen((results) {
  //     newPeripherals = results;
  //     peripherals = newPeripherals;
  //     print(newPeripherals.length);
  //     notifyListeners();
  //   });
  //   await Future.delayed(const Duration(seconds: 4));
  //   ble.stopScan();
  //   print("end");
  //   return peripherals;
  // }
}
