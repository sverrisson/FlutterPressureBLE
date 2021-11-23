import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../settings/settings_view.dart';
import 'sensor_view.dart';

/// Displays a list of SampleItems.
class SensorListView extends StatelessWidget {
  const SensorListView({Key? key, this.devices = const []}) : super(key: key);

  final List<ScanResult> devices;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Device'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),

      // To work with lists that may contain a large number of items, it’s best
      // to use the ListView.builder constructor.
      //
      // In contrast to the default ListView constructor, which requires
      // building all Widgets up front, the ListView.builder constructor lazily
      // builds Widgets as they’re scrolled into view.
      body: ListView.builder(
        // Providing a restorationId allows the ListView to restore the
        // scroll position when a user leaves and returns to the app after it
        // has been killed while running in the background.
        restorationId: 'sampleItemListView',
        itemCount: devices.length,
        itemBuilder: (BuildContext context, int index) {
          final device = devices[index];

          return ListTile(
              title: Text('Device: ${device.advertisementData.localName}'),
              leading: const CircleAvatar(
                // Display the Flutter Logo image asset.
                foregroundImage: AssetImage('assets/images/flutter_logo.png'),
              ),
              onTap: () {
                // Navigate to the details page. If the user leaves and returns to
                // the app after it has been killed while running in the
                // background, the navigation stack is restored.
                Navigator.restorablePushNamed(
                  context,
                  SensorView.routeName,
                  arguments: <String, String>{
                    'deviceIdentifier': device.device.id.toString(),
                  },
                );
              });
        },
      ),
    );
  }
}
