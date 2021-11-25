import 'package:ble_pressure/src/ble/ble_state_model.dart';
import 'package:ble_pressure/src/sample_feature/services_list_view.dart';
import 'package:ble_pressure/src/settings/settings_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ServicesConsumer extends StatefulWidget {
  const ServicesConsumer({Key? key}) : super(key: key);

  static const routeName = '/services';

  @override
  _ServicesConsumerState createState() => _ServicesConsumerState();
}

class _ServicesConsumerState extends State<ServicesConsumer> {
  @override
  Widget build(BuildContext context) {
    return Consumer<BleStateModel>(
      builder: (context, ble, child) {
        if (ble.services.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Find Device'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    // Navigate to the settings page. If the user leaves and returns
                    // to the app after it has been killed while running in the
                    // background, the navigation stack is restored.
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
          return ServicesListView(services: ble.services);
        }
      },
    );
  }
}
