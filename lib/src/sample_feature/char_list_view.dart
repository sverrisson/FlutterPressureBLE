import 'package:ble_pressure/src/ble/ble_state_model.dart';
import 'package:ble_pressure/src/settings/settings_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

/// Displays a list of Characteristics.
class CharListView extends StatefulWidget {
  const CharListView({Key? key, this.chars = const []}) : super(key: key);

  final List<BluetoothCharacteristic> chars;

  @override
  _CharListViewState createState() => _CharListViewState();
}

class _CharListViewState extends State<CharListView> {
  final Map<int, String> _map = {};

  @override
  void initState() {
    super.initState();
    final ble = Provider.of<BleStateModel>(context, listen: false);
    final chars = ble.characteristics;
    chars.forEachIndexed((index, char) {
      ble.readDescriptor(char).then((value) {
        _map[index] = value.join(" <> ");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    BluetoothDevice? device =
        Provider.of<BleStateModel>(context, listen: false).device;
    return Scaffold(
      appBar: AppBar(
        title: Text('${device?.name}'),
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
        itemCount: widget.chars.length,
        itemBuilder: (BuildContext context, int index) {
          final char = widget.chars[index];
          return ListTile(
            title: Text('Char: ${char.uuid.toString().substring(6, 8)}'),
            subtitle: Text(_map[index] ??
                Provider.of<BleStateModel>(context, listen: false)
                    .readProperties(char)),
            leading: const Icon(
              Icons.bluetooth_connected,
              size: 36,
              color: Colors.blueAccent,
            ),
            onTap: () {
              Provider.of<BleStateModel>(context, listen: false)
                  .readData(char)
                  .listen(
                (value) {
                  Fluttertoast.showToast(
                      msg: value,
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.deepOrange,
                      textColor: Colors.white,
                      fontSize: 16.0);
                  setState(() {
                    _map[index] = value;
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}
