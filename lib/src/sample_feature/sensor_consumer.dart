import 'package:ble_pressure/src/ble/ble_state_model.dart';
import 'package:ble_pressure/src/sample_feature/sensor_list_view.dart';
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
        if (ble.devices.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Find Device'),
              actions: [
                IconButton(
                  icon: Icon(
                    (ble.status != BleStatus.scanning)
                        ? Icons.bluetooth
                        : Icons.stop,
                  ),
                  onPressed: () {
                    if (ble.status == BleStatus.unknown ||
                        ble.status == BleStatus.idle) {
                      if (ble.devices.isEmpty) {
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (ble.status == BleStatus.unknown ||
                          ble.status == BleStatus.idle) {
                        if (ble.devices.isEmpty) {
                          ble.scan();
                        }
                      } else {
                        if (ble.status != BleStatus.idle) {
                          ble.stop();
                        }
                      }
                    },
                    child: (ble.status != BleStatus.scanning)
                        ? const Text('Start Scanning')
                        : const Text('Stop'),
                  ),
                  (ble.status == BleStatus.scanning)
                      ? const CircularProgressIndicator()
                      : Container(),
                ],
              ),
            ),
          );
        } else {
          return SensorListView(devices: ble.devices);
        }
      },
    );
  }
}
