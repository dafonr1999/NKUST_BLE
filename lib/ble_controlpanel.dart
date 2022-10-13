
import 'package:flutter/material.dart';
import 'package:nkust_ble/scanpage.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:nkust_ble/widgets.dart';

class ble_controlpanel extends StatefulWidget {
  ble_controlpanel({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BLE_controlpanel_state();
  }
}

class BLE_controlpanel_state extends State<ble_controlpanel> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                    //從登入push到第二個
                    context,
                    MaterialPageRoute(builder: (context) => scanpage()),
                  );
                },
                icon: const Icon(Icons.bluetooth_searching))
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () =>
              FlutterBlue.instance.startScan(timeout: Duration(seconds: 4)),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                StreamBuilder<List<BluetoothDevice>>(
                  stream: Stream.periodic(const Duration(seconds: 1))
                      .asyncMap((_) => FlutterBlue.instance.connectedDevices),
                  initialData: [],
                  builder: (c, snapshot) => Column(
                    children: snapshot.data!
                        .map((d) => ListTile(
                              title: Text(d.name),
                              subtitle: Text(d.id.toString()),
                              trailing: StreamBuilder<BluetoothDeviceState>(
                                stream: d.state,
                                initialData: BluetoothDeviceState.disconnected,
                                builder: (c, snapshot) {
                                  if (snapshot.data ==
                                      BluetoothDeviceState.connected) {
                                    return ElevatedButton(
                                      child: const Text('disconnect'),
                                      onPressed: () {
                                        d.disconnect();
                                        // Navigator.of(context).push(
                                        //     MaterialPageRoute(
                                        //         builder: (context) =>
                                        //             DeviceScreen(device: d)));
                                      },
                                    );
                                  }
                                  return Text(snapshot.data.toString());
                                },
                              ),
                            ))
                        .toList(),
                  ),
                ),

              ],
            ),
          ),
        ));
  }
}
