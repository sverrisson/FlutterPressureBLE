import 'package:ble_pressure/src/ble/ble_state_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';
import '../settings/settings_view.dart';
import 'sensor_view.dart';

/// Displays a list of SampleItems.
class SensorListView extends StatelessWidget {
  const SensorListView({Key? key, this.scanned = const []}) : super(key: key);

  final List<ScanResult> scanned;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Device'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              Provider.of<BleStateModel>(context, listen: false).removeAll();
            },
          ),
        ],
      ),
      body: ListView.builder(
        restorationId: 'sensorListView',
        itemCount: scanned.length,
        itemBuilder: (BuildContext context, int index) {
          final device = scanned[index];
          return ListTile(
            title: Text('Device: ${device.advertisementData.localName}'),
            leading: const Icon(
              Icons.bluetooth_connected,
              size: 32,
              color: Colors.blueAccent,
            ),
            onTap: () {
              Provider.of<BleStateModel>(context, listen: false)
                  .selectScanResult(device);
              Navigator.restorablePushNamed(
                context,
                SensorView.routeName,
              );
            },
          );
        },
      ),
    );
  }
}
