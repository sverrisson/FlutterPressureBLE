import 'package:ble_pressure/src/ble/ble_state_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';

/// Displays detailed information about a SampleItem.
class SensorView extends StatefulWidget {
  const SensorView({Key? key}) : super(key: key);

  static const routeName = '/sample_item';

  @override
  _SensorViewState createState() => _SensorViewState();
}

class _SensorViewState extends State<SensorView> {
  String services = "";

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    fn();
  }

  @override
  Widget build(BuildContext context) {
    ScanResult? device =
        Provider.of<BleStateModel>(context, listen: true).selected;

    return Consumer<BleStateModel>(
      builder: (context, ble, child) {
        AdvertisementData? data = device?.advertisementData;
        return Scaffold(
          appBar: AppBar(
            title: Text(data?.localName ?? 'Nothing Selected'),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data?.localName ?? 'Nothing Selected',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  Text(
                    data?.serviceUuids.toString() ?? 'Unknown',
                    style: Theme.of(context).textTheme.caption,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          await ble.connect(device?.device);
                          ble
                              .services(device?.device)
                              .then((value) => setState(() {
                                    services = value;
                                  }));
                        },
                        child: const Text('Show Services'),
                      ),
                    ),
                  ),
                  Text(services),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
