import 'package:ble_pressure/src/ble/ble_state_model.dart';
import 'package:ble_pressure/src/settings/settings_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';

import 'char_consumer.dart';

/// Displays a list of Services.
class ServicesListView extends StatelessWidget {
  const ServicesListView({Key? key, this.services = const []})
      : super(key: key);

  final List<BluetoothService> services;

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
        restorationId: 'servicesListView',
        itemCount: services.length,
        itemBuilder: (BuildContext context, int index) {
          final service = services[index];
          return ListTile(
            title: Text('Service: ${service.uuid.toString().substring(4, 8)}'),
            leading: const Icon(
              Icons.bluetooth_connected,
              size: 36,
              color: Colors.blueAccent,
            ),
            onTap: () {
              Provider.of<BleStateModel>(context, listen: false)
                  .readCharacteristics(service);
              Navigator.restorablePushNamed(
                context,
                CharConsumer.routeName,
              );
            },
          );
        },
      ),
    );
  }
}
