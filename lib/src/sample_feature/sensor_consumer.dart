import 'package:ble_pressure/src/ble/ble_state_model.dart';
import 'package:ble_pressure/src/sample_feature/sensor_list_view.dart';
import 'package:ble_pressure/src/settings/settings_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SensorConsumerView extends StatefulWidget {
  const SensorConsumerView({Key? key}) : super(key: key);

  static const routeName = '/';

  @override
  _SensorConsumerViewState createState() => _SensorConsumerViewState();
}

class _SensorConsumerViewState extends State<SensorConsumerView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<BleStateModel>(
      builder: (context, ble, child) {
        if (ble.scanned.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Getting Services'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.restorablePushNamed(
                        context, SettingsView.routeName);
                  },
                ),
                IconButton(
                  icon: Icon(
                    (ble.status != BleStatus.scanning)
                        ? Icons.bluetooth
                        : Icons.stop,
                  ),
                  onPressed: () {
                    if (ble.status == BleStatus.unknown ||
                        ble.status == BleStatus.idle) {
                      if (ble.scanned.isEmpty) {
                        ble.scan();
                      }
                    } else {
                      if (ble.status != BleStatus.idle) {
                        ble.stop();
                      }
                    }
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
                    ElevatedButton(
                      onPressed: () {
                        if (ble.status == BleStatus.unknown ||
                            ble.status == BleStatus.idle) {
                          if (ble.scanned.isEmpty) {
                            ble
                                .scan(
                                  serviceUuids: BleStateModel.findServiceUuids,
                                )
                                .then((value) => setState(() {}));
                          }
                        } else {
                          if (ble.status != BleStatus.idle) {
                            ble.stop();
                          }
                        }
                      },
                      child: (ble.status != BleStatus.scanning)
                          ? const Text('Scan for Pressure-BJ')
                          : const Text('Stop'),
                    ),
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
          return SensorListView(scanned: ble.scanned);
        }
      },
    );
  }
}
