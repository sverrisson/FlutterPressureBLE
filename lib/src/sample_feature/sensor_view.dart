import 'package:ble_pressure/src/ble/ble_manager.dart';
import 'package:ble_pressure/src/ble/ble_state_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';

/// Displays detailed information about a SampleItem.
class SensorView extends StatelessWidget {
  SensorView({Key? key}) : super(key: key);

  static const routeName = '/sample_item';

// Provider.of<CartModel>(context, listen: false).removeAll();

  @override
  Widget build(BuildContext context) {
    // var id = DeviceIdentifier(deviceIdentifier ?? "");
    // var device = BleManager.instance.peripherals
    //     .firstWhere((device) => device.device.id == id);
    return Consumer<BleStateModel>(
      builder: (context, ble, child) {
        AdvertisementData data =
            ble.devices[ble.selected ?? 0].advertisementData;
        return Scaffold(
          appBar: AppBar(
            title: Text(data.localName),
          ),
          body: Center(
            child: Text(data.serviceUuids.toString()),
          ),
        );
      },
    );
  }
}
