import 'dart:async';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:hex/hex.dart';
import 'global.dart' as GV;

class ScanResultTile extends StatelessWidget {
  const ScanResultTile({Key? key, required this.result, this.onTap})
      : super(key: key);

  final ScanResult result;
  final VoidCallback? onTap;

  Widget _buildTitle(BuildContext context) {
    if (result.device.name.isNotEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            result.device.name,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            result.device.id.toString(),
            style: Theme.of(context).textTheme.caption,
          )
        ],
      );
    } else {
      return Text(result.device.id.toString());
    }
  }

  Widget _buildAdvRow(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.caption),
          const SizedBox(
            width: 12.0,
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .caption
                  ?.apply(color: Colors.black),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  String getNiceHexArray(List<int> bytes) {
    return '[${bytes.map((i) => i.toRadixString(16).padLeft(2, '0')).join(', ')}]'
        .toUpperCase();
  }

  String getNiceManufacturerData(Map<int, List<int>> data) {
    if (data.isEmpty) {
      return 'N/A';
    }
    List<String> res = [];
    data.forEach((id, bytes) {
      res.add(
          '${id.toRadixString(16).toUpperCase()}: ${getNiceHexArray(bytes)}');
    });
    return res.join(', ');
  }

  String getNiceServiceData(Map<String, List<int>> data) {
    if (data.isEmpty) {
      return 'N/A';
    }
    List<String> res = [];
    data.forEach((id, bytes) {
      res.add('${id.toUpperCase()}: ${getNiceHexArray(bytes)}');
    });
    return res.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: _buildTitle(context),
      leading: Text(result.rssi.toString()),
      trailing: ElevatedButton(
        child: const Text('CONNECT'),
        onPressed: (result.advertisementData.connectable) ? onTap : null,
      ),
      children: <Widget>[
        _buildAdvRow(
            context, 'Complete Local Name', result.advertisementData.localName),
        _buildAdvRow(context, 'Tx Power Level',
            '${result.advertisementData.txPowerLevel ?? 'N/A'}'),
        _buildAdvRow(context, 'Manufacturer Data',
            getNiceManufacturerData(result.advertisementData.manufacturerData)),
        _buildAdvRow(
            context,
            'Service UUIDs',
            (result.advertisementData.serviceUuids.isNotEmpty)
                ? result.advertisementData.serviceUuids.join(', ').toUpperCase()
                : 'N/A'),
        _buildAdvRow(context, 'Service Data',
            getNiceServiceData(result.advertisementData.serviceData)),
      ],
    );
  }
}

class ServiceTile extends StatelessWidget {
  final BluetoothService service;
  final List<CharacteristicTile> characteristicTiles;

  const ServiceTile(
      {Key? key, required this.service, required this.characteristicTiles})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (characteristicTiles.isNotEmpty) {
      return Column(
        children: [
          ListTile(
              title: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                const Text('Service'),
                Text(
                  '0x${service.uuid.toString().toUpperCase().substring(4, 8)}',
                )
              ])),
          Column(children: characteristicTiles)
        ],
      );
    } else {
      return ListTile(
        title: const Text('Service'),
        subtitle:
            Text('0x${service.uuid.toString().toUpperCase().substring(4, 8)}'),
      );
    }
  }
}

class CharacteristicTile extends StatefulWidget {
  final BluetoothCharacteristic characteristic;

  final VoidCallback? onReadPressed;
  final VoidCallback? onWritePressed;

  final VoidCallback? onNotificationPressed;

  const CharacteristicTile(
      {Key? key,
      required this.characteristic,
      // required this.descriptorTiles,
      this.onReadPressed,
      this.onWritePressed,
      this.onNotificationPressed})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CharacteristicTilestate();
  }
}

class CharacteristicTilestate extends State<CharacteristicTile> {
  final myController = TextEditingController();
  var receiveController = TextEditingController();
  List<btdata> receivelist = [];
  var value = '';
  late StreamSubscription<List<int>> streamSubscription;


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextButton(
              child: const Text('刪除歷史資料'),
              onPressed: () {
                setState(() {
                  receivelist.clear();
                });
              },
            ),
            TextButton(
              child: const Text('啟用特徵通知'),
              onPressed: widget.onNotificationPressed,
            )
          ],
        ),

        Column(
          children: [
GV.receivemode==0?
                 Row(children: [
                    Expanded(
                      child:

                      TextField(
autofocus: true,
                    //       onChanged: (text) {
                    //
                    // String tmp = text.replaceAll(' ', '');
                    // String output='';
                    //   for(int i=0;i<tmp.length;i++){
                    //     if(i.isEven&&i>0){
                    //       output=output+'  ';
                    //     }
                    //     output=output+tmp[i];
                    //
                    //   }
                    //  myController.text=output;
                    //         myController.selection = TextSelection.fromPosition(TextPosition(offset: myController.text.length));
                    //
                    //       },
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp('[a-zA-Z 0-9]')),

                          ],
                          decoration: const InputDecoration(

                              border: OutlineInputBorder(), labelText: '傳送資料'),
                          controller: myController,
                          style:
                              const TextStyle(height: 1,
                                  fontSize: 25,
                                  color: Colors.black)),
                      flex: 4,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        child: const Text('送出'),
                        onPressed: () async {
                          try {
                            List<int> textdata = [];
                            textdata.addAll(HEX.decode(myController.text));
                            textdata.add(0x0d);
                            await widget.characteristic.write(textdata);

                            print(textdata);
                          } catch (e) {
                            print(e.toString());
                          }
                        },

                      ),
                      flex: 1,
                    )
                  ]):Container(),

            SingleChildScrollView(
              child: SizedBox(
                height: 600,
                child: ListView(
                  shrinkWrap: true,
                  children: receivelist.map((e) {
                    String transdata = '';
                    switch (GV.receivemode) {
                      case (0):
                        {
                          transdata = latin1.decode(e.receivedata).trim();
                          break;
                        }
                      case (1):
                        {
                          try {
                            double c = (e.receivedata[0] - 32) * 5 / 9;
                            transdata = e.receivedata[0].toString() +
                                'f , ' +
                                c.toStringAsFixed(2) +
                                'c';
                          } catch (e) {
                            transdata = '格式錯誤 無法轉換';
                          }

                          break;
                        }
                      case (2):
                        {
                          try {
                            double out = (e.receivedata[0] * 65536 +
                                    e.receivedata[1] * 256 +
                                    e.receivedata[2] * 16)
                                .toDouble();
                            double tout = (out - 1677722) * 25 / 13421772;

                            transdata = tout.toStringAsFixed(3) + 'PSI';
                          } catch (e) {
                            transdata = '格式錯誤 無法轉換';
                          }

                          break;
                        }
                      case (3):
                        {
                          try {
                            double pout = (e.receivedata[0] * 65536 +
                                    e.receivedata[1] * 256 +
                                    e.receivedata[2] * 16)
                                .toDouble();
                            double Pbar = (pout - 1677722) * 10 / 13421772;

                            double tout = (e.receivedata[3] * 65536 +
                                    e.receivedata[4] * 256 +
                                    e.receivedata[5] * 16)
                                .toDouble();
                            double toc = (tout - 1677722) * 200 / 13421772 - 50;

                            transdata = Pbar.toStringAsFixed(3) +
                                'Bar ,' +
                                toc.toStringAsFixed(3) +
                                'oC';
                          } catch (e) {
                            transdata = '格式錯誤 無法轉換';
                          }

                          break;
                        }
                    }

                    return Card(
                      child: ListTile(
                        title: Text('${e.receivedata}\n$transdata '),
                        subtitle: Text(e.receivetime),
                        trailing: IconButton(
                          icon: Icon(Icons.delete,
                              color: Theme.of(context)
                                  .iconTheme
                                  .color
                                  ?.withOpacity(0.5)),
                          onPressed: () {
                            setState(() {
                              receivelist.remove(e);
                            });
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            )
          ],
        )

        // : Container()
      ],
    );
  }

  @override
  void dispose() {
    if (!streamSubscription.isPaused) {
      streamSubscription.cancel();
    }
    myController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (!widget.characteristic.isNotifying) {
      () async {
        widget.characteristic.setNotifyValue(true);
      };
    }

    streamSubscription = widget.characteristic.value.listen((event) {
      if (event.isNotEmpty) {
        setState(() {
          double c = (event[0] - 32).toDouble() * 5 / 9;
          if (receivelist.length == 250) {
            receivelist.clear();
          }
          receivelist.insert(0, btdata(event));
          // receivelist.insert(0, btdata(latin1.decode(event).trim()));
        });
      }
    });
  }
}

class DescriptorTile extends StatelessWidget {
  final BluetoothDescriptor descriptor;
  final VoidCallback? onReadPressed;
  final VoidCallback? onWritePressed;

  const DescriptorTile(
      {Key? key,
      required this.descriptor,
      this.onReadPressed,
      this.onWritePressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Descriptor'),
          Text(
            '0x${descriptor.uuid.toString().toUpperCase().substring(4, 8)}',
          )
        ],
      ),
      subtitle: StreamBuilder<List<int>>(
        stream: descriptor.value,
        initialData: descriptor.lastValue,
        builder: (c, snapshot) => Text(snapshot.data.toString()),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.file_download,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
            ),
            onPressed: onReadPressed,
          ),
          IconButton(
            icon: Icon(
              Icons.file_upload,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
            ),
            onPressed: onWritePressed,
          )
        ],
      ),
    );
  }
}

class AdapterStateTile extends StatelessWidget {
  const AdapterStateTile({Key? key, required this.state}) : super(key: key);

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.redAccent,
      child: ListTile(
        title: Text(
          'Bluetooth adapter is ${state.toString().substring(15)}',
        ),
        trailing: const Icon(
          Icons.error,
        ),
      ),
    );
  }
}

// class controllpanel extends StatefulWidget {
//   BluetoothService service;
//
//   controllpanel({Key? key, required this.service}) : super(key: key);
//
//   @override
//   State<StatefulWidget> createState() {
//     return controlstate();
//   }
// }
//
// class controlstate extends State<controllpanel> {
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     throw UnimplementedError();
//   }
// }

class btdata {
  String receivetime = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
  List<int> receivedata;

  btdata(this.receivedata);
}
