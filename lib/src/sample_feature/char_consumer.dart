import 'package:ble_pressure/src/ble/ble_state_model.dart';
import 'package:ble_pressure/src/settings/settings_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'char_list_view.dart';

class CharConsumer extends StatefulWidget {
  const CharConsumer({Key? key}) : super(key: key);

  static const routeName = '/chars';

  @override
  _CharConsumerState createState() => _CharConsumerState();
}

class _CharConsumerState extends State<CharConsumer> {
  @override
  Widget build(BuildContext context) {
    return Consumer<BleStateModel>(
      builder: (context, ble, child) {
        if (ble.characteristics.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Getting Characteristics'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.restorablePushNamed(
                        context, SettingsView.routeName);
                  },
                ),
              ],
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(36),
                      child: (ble.status == BleStatus.scanning)
                          ? const CircularProgressIndicator()
                          : Container(),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return CharListView(chars: ble.characteristics);
        }
      },
    );
  }
}
