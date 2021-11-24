import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:simple_logger/simple_logger.dart';

enum BleStatus { unknown, scanning, idle, unavailable }

class BleStateModel extends ChangeNotifier {
  /// Internal, private state
  List<ScanResult> _devices = [];
  int? _index;
  BleStatus _status = BleStatus.unknown;
  List<BluetoothService>? _services;
  List<BluetoothCharacteristic>? _chars;
  final log = SimpleLogger();

  FlutterBlue bleManager = FlutterBlue.instance;
  static List<Guid> get findServiceUuids =>
      [Guid("7E4148A0-AB23-4DC2-A36F-471884A30548")];

  /// List of scanned devices
  List<ScanResult> get devices => _devices;

  /// Current selected device.
  ScanResult? get selected => (_index != null) ? devices[_index!] : null;

  /// Current status.
  BleStatus get status => _status;

  List<BluetoothService>? get services => _services;
  List<BluetoothCharacteristic>? get characteristics => _chars;

  Future<String> readData(BluetoothCharacteristic? char) async {
    if (char == null) return "";
    String string = "";
    char.read().then((value) {
      string = utf8.decode(value, allowMalformed: true);
      log.info("☢️ Data read: $string");
    });
    return string;
  }

  Future<void> writeInt(BluetoothCharacteristic? char, int value) async {
    return writeData(char, [value]);
  }

  Future<void> writeData(
      BluetoothCharacteristic? char, List<int> buffer) async {
    if (char == null) return;
    await char.write(buffer, withoutResponse: false);
    log.info("☢️ Data written: $buffer");
    return;
  }

  Future<Stream<List<int>>> notifyStream(BluetoothCharacteristic? char) async {
    if (char == null) return const Stream.empty();
    await char.setNotifyValue(true).then((ready) {
      log.info("☢️ NotifyStream from char: ${char.serviceUuid}");
    });
    return char.value;
    // char.value.listen((data) {
    //   log.info("☢️ Notify data: $data");
    //   Stream.fromIterable(data);
    // }, onDone: () {
    //   log.info("☢️ Notify Done for: $char");
    // }, onError: (error) {
    //   // log.error("☢️ Notify Error: $error");
    // });
  }

  Future<void> connect(BluetoothDevice? device) async {
    if (device == null) return;
    log.info("☢️ Connect to device: ${device.toString()}");
    await device.connect();
  }

  Future<String> readServices(BluetoothDevice? device) async {
    String result = "";
    if (device == null) return result;
    log.info("☢️ Services for device: ${device.name}");
    final services = await device.discoverServices();
    _services = services;
    // log.info("☢️ ${services.toString()}");
    for (var service in services) {
      result += "[Service: ${service.uuid}\n";
      final chars = service.characteristics;
      // log.info("☢️ Chars: ${chars.toString()}");
      for (var char in chars) {
        // log.info("☢️ ${char.toString()}");
        result += "   - char: ${char.uuid}\n";
      }
    }
    result += "]\n";
    log.info("☢️ Finished");
    log.info("☢️ Result: $result");
    return result;
  }

  /// Scans for available peripherals
  void scan({List<Guid> serviceUuids = const []}) {
    if (_devices.isNotEmpty) {
      removeAll();
    }
    _status = BleStatus.scanning;
    bleManager.startScan(
      withServices: serviceUuids,
      timeout: const Duration(seconds: 12),
    );
    log.info("☢️ StartScan");

    bleManager.scanResults.listen((results) {
      _devices = results;
      log.info("☢️ Found ${results.length} devices");
      notifyListeners();
    });
  }

  /// Devices is selected and stops scanning.
  void selectDevice(ScanResult device) {
    stop();
    _status = BleStatus.idle;

    // Why is indexWhere not nullable?
    final item =
        _devices.indexWhere((item) => item.device.id == device.device.id);
    item == -1 ? _index = null : _index = item;
  }

  /// Removes all items from the cart.
  void stop() {
    if (_status == BleStatus.scanning) {
      log.info("☢️ Stoop Scanning");
      bleManager.stopScan();
      _status = BleStatus.idle;
    }
  }

  /// Removes all items from the cart.
  void removeAll() {
    stop();
    log.info("☢️ Clear Devices");
    _index = null;
    _devices.clear();
    _status = BleStatus.unknown;
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }
}
