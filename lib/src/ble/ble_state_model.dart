import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:simple_logger/simple_logger.dart';

enum BleStatus { unknown, scanning, idle, unavailable, connected }

class BleStateModel extends ChangeNotifier {
  /// Internal, private state
  List<ScanResult> _scanResults = [];
  BluetoothDevice? _device;
  int? _index;
  BleStatus _status = BleStatus.unknown;
  List<BluetoothService> _services = [];
  List<BluetoothCharacteristic> _chars = [];
  final log = SimpleLogger();

  FlutterBlue bleManager = FlutterBlue.instance;
  static List<Guid> get findServiceUuids =>
      [Guid("7E4148A0-AB23-4DC2-A36F-471884A30548")];

  /// List of scanned devices
  List<ScanResult> get scanned => _scanResults;

  /// Current selected device.
  ScanResult? get selected => (_index != null) ? _scanResults[_index!] : null;

  /// Current status.
  BleStatus get status => _status;

  BluetoothDevice? get device => _device;
  List<BluetoothService> get services => _services;
  List<BluetoothCharacteristic> get characteristics => _chars;

  /// Read data from a characteristic
  Stream<String> readData(BluetoothCharacteristic? char) {
    if (char == null) return const Stream<String>.empty();
    if (status != BleStatus.connected) {
      assert(status == BleStatus.connected, "A device is NOT connected");
      return const Stream<String>.empty();
    }
    if (!char.properties.read) {
      assert(char.properties.read, "☢️ Data: char is NOT readable");
      return const Stream<String>.empty();
    }
    return char.read().asStream().map((values) {
      String string = utf8.decode(values, allowMalformed: true);
      log.info("☢️ Data read: $string");
      return string;
    });
  }

  /// Write an int to a characteristic
  Future<void> writeInt(BluetoothCharacteristic? char, int value) async {
    return writeData(char, [value]);
  }

  /// Write to a characteristic
  Future<void> writeData(
      BluetoothCharacteristic? char, List<int> buffer) async {
    if (char == null) return;
    if (status != BleStatus.connected) {
      assert(status == BleStatus.connected, "A device is NOT connected");
      return;
    }
    if (!char.properties.write) {
      assert(char.properties.write, "☢️ Data: char is NOT writeable");
      return;
    }
    await char.write(buffer, withoutResponse: false);
    log.info("☢️ Data written: $buffer");
    return;
  }

  /// Listen to a notify characteristic
  Future<Stream<List<int>>> notifyStream(BluetoothCharacteristic? char) async {
    if (char == null) return const Stream.empty();
    if (status != BleStatus.connected) {
      assert(status == BleStatus.connected, "A device is NOT connected");
      return const Stream.empty();
    }
    if (!char.properties.notify) {
      assert(char.properties.notify, "☢️ Data: char is NOT notifiable");
      return const Stream.empty();
    }
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

  /// Read properties for a characteristic
  String readProperties(BluetoothCharacteristic? char) {
    if (char == null) return '';
    if (status != BleStatus.connected) {
      assert(status == BleStatus.connected, "A device is NOT connected");
      return '';
    }
    return char.properties.toString();
  }

  /// Read a descriptor for a characteristic
  Future<List<String>> readDescriptor(BluetoothCharacteristic? char) async {
    if (char == null) return [];
    if (status != BleStatus.connected) {
      assert(status == BleStatus.connected, "A device is NOT connected");
      return [];
    }
    if (char.descriptors.isEmpty) {
      assert(char.descriptors.isNotEmpty, "☢️ Data: char has no descriptor");
      return [];
    }
    final desc = char.descriptors;
    List<String> descriptors = [];
    for (var des in desc) {
      final values = await des.read();
      String string = utf8.decode(values, allowMalformed: true);
      descriptors.add(string);
      log.info("☢️ Descriptor: $string");
    }
    return descriptors;
  }

  /// Connect to the device
  Future<void> connect(BluetoothDevice? device,
      {bool scanForServices = false}) async {
    if (device == null) return;
    if (status == BleStatus.connected) {
      assert(status != BleStatus.connected, "Device is already connected");
      await device.disconnect();
    }
    log.info("☢️ Connect to device: ${device.toString()}");
    await device.connect();
    _status = BleStatus.connected;
    _device = device;
    if (scanForServices) {
      await readServices(device);
    }
  }

  /// Scans for available peripherals
  Future<List<BluetoothService>> readServices(BluetoothDevice? device) async {
    if (device == null) return [];
    if (status != BleStatus.connected) {
      assert(status == BleStatus.connected, "A device is NOT connected");
      return [];
    }
    log.info("☢️ Services for device: ${device.name}");
    final services = await device.discoverServices();
    for (var service in services) {
      log.info("☢️ ${service.uuid}");
    }
    _services = services;
    return services;
  }

  /// Scans for available peripherals
  Future<List<BluetoothCharacteristic>> readCharacteristics(
      BluetoothService service) async {
    if (status != BleStatus.connected) {
      assert(status == BleStatus.connected, "A device is NOT connected");
      return [];
    }
    final chars = service.characteristics;
    log.info("☢️ Chars for service: ${service.uuid}");
    for (var char in chars) {
      log.info("☢️ ${char.uuid}");
    }
    _chars = chars;
    return chars;
  }

  /// Scans for available peripherals
  Future<void> scan({List<Guid> serviceUuids = const []}) async {
    if (_scanResults.isNotEmpty) {
      removeAll();
    }
    _status = BleStatus.scanning;
    bleManager
        .startScan(
      withServices: serviceUuids,
      timeout: const Duration(seconds: 5),
    )
        .then((value) {
      _scanResults = value;
      _status = BleStatus.idle;
      log.info("☢️ Scanning ended, found: ${_scanResults.length} devices");
      notifyListeners();
      return;
    });
    log.info("☢️ Scanning Started");
  }

  /// Devices is selected and stops scanning.
  void selectScanResult(ScanResult scanResult) {
    stop();
    _status = BleStatus.idle;

    // Why is indexWhere not nullable?
    final item = _scanResults
        .indexWhere((item) => item.device.id == scanResult.device.id);
    item == -1 ? _index = null : _index = item;
  }

  /// Removes all items from the cart.
  void stop() async {
    if (status == BleStatus.connected) {
      await device?.disconnect();
    }
    if (_status == BleStatus.scanning) {
      log.info("☢️ Stop Scanning, found: ${_scanResults.length} devices");
      bleManager.stopScan();
      _status = BleStatus.idle;
    }
  }

  /// Removes all items from the cart.
  void removeAll() {
    stop();
    log.info("☢️ Clear Devices");
    _index = null;
    _scanResults.clear();
    _status = BleStatus.unknown;
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }
}
