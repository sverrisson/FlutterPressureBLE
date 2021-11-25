import 'package:ble_pressure/src/ble/ble_state_model.dart';
import 'package:ble_pressure/src/settings/settings_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';

/// Displays a list of Characteristics.
class CharListView extends StatelessWidget {
  const CharListView({Key? key, this.chars = const []}) : super(key: key);

  final List<BluetoothCharacteristic> chars;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${Provider.of<BleStateModel>(context, listen: false).selected?.device.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      body: ListView.builder(
        restorationId: 'charListView',
        itemCount: chars.length,
        itemBuilder: (BuildContext context, int index) {
          final char = chars[index];

          return ListTile(
            title: Text('Char: ${char.uuid}'),
            leading: const Icon(
              Icons.bluetooth_connected,
              size: 36,
              color: Colors.blueAccent,
            ),
            onTap: () {
              Provider.of<BleStateModel>(context, listen: false).readData(char);
            },
          );
        },
      ),
    );
  }
}
