import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:hex/hex.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nkust_ble/scanpage.dart';
import 'package:flutter_blue/flutter_blue.dart';

class terminal extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return terminalstate();
  }
}

class terminalstate extends State<terminal> with TickerProviderStateMixin {
  TabController? tabController;

  var features = ['Terminal' ,'Demo_Temperature'];
  int mode = 0;
  Map<String, StreamSubscription> Subscriptions = {};
  Map<String, List<btdata>> btdataList = {};
  Map<String, String> devicenamelist = {};

  @override
  void initState() {
    super.initState();
    FlutterBlue.instance.connectedDevices.then((value) {
      if (value.isNotEmpty) {
        setState(() {});
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: btdataList.length,
        child: Scaffold(
            appBar: AppBar(
              title: Text('Mode:' + features[mode]),
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.push(
                        //從登入push到第二個
                        context,
                        MaterialPageRoute(builder: (context) => scanpage()),
                      ).then((value) => setState(() {}));
                    },
                    icon: const Icon(Icons.search)),
                PopupMenuButton(
                  icon: Icon(Icons.more_vert),
                  itemBuilder: (BuildContext context) => <PopupMenuEntry>[

                    PopupMenuItem(
                      child: ListTile(
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            mode = 0;
                          });
                        },
                        title: const Text('Terminal'),
                      ),
                    ),


                    PopupMenuItem(
                      child: ListTile(
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            mode = 1;
                          });
                        },
                        title: const Text('Demo_temperature'),
                      ),
                    ),

                  ],
                ),
              ],
            ),
            body: Column(children: [
              StreamBuilder<List<BluetoothDevice>>(
                  stream: Stream.periodic(const Duration(seconds: 1)).asyncMap((_) => FlutterBlue.instance.connectedDevices),
                  initialData: [],
                  builder: (c, snapshot) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: snapshot.data!.map((d) {
                        return ListTile(
                          title: Text(d.name),
                          subtitle: Text(d.id.toString()),
                          trailing: StreamBuilder<BluetoothDeviceState>(
                            stream: d.state,
                            initialData: BluetoothDeviceState.disconnected,
                            builder: (c, snapshot) {
                              if (snapshot.data == BluetoothDeviceState.connected) {
                                discoverservice(d);
                                return const Text('Connecting');
                              } else {
                                return ElevatedButton(
                                  child: const Text('Reconnect'),
                                  onPressed: () async {
                                    await d.connect(timeout: const Duration(seconds: 5), autoConnect: false).then((value) => setState(() {}));
                                  },
                                );
                              }
                            },
                          ),
                        );
                      }).toList(),
                    );
                  }),
              const Divider(color: Colors.black),
              Expanded(
                  child: TabBarView(
                      children: btdataList.values
                          .map((value) => ListView(
                                shrinkWrap: true,
                                children: value.map((e) {
                                  String transdata = '';
                                  switch (mode) {
                                    case (0):
                                      {
                                        transdata = latin1.decode(e.receivedata).trim();
                                        break;
                                      }
                                    case (1):
                                      {
                                        try {
                                          double c = (e.receivedata[0] - 32) * 5 / 9;
                                          transdata = e.receivedata[0].toString() + '°f , ' + c.toStringAsFixed(2) + '°c';
                                        } catch (e) {
                                          transdata = 'Erro';
                                        }
                                        break;
                                      }
                                    case (2):
                                      {
                                        try {
                                          double out = (e.receivedata[0] * 65536 + e.receivedata[1] * 256 + e.receivedata[2] * 16).toDouble();
                                          double tout = (out - 1677722) * 25 / 13421772;
                                          transdata = tout.toStringAsFixed(3) + 'PSI';
                                        } catch (e) {
                                          transdata = 'Erro';
                                        }

                                        break;
                                      }
                                    case (3):
                                      {
                                        try {
                                          double pout = (e.receivedata[0] * 65536 + e.receivedata[1] * 256 + e.receivedata[2] * 16).toDouble();
                                          double Pbar = (pout - 1677722) * 10 / 13421772;

                                          double tout = (e.receivedata[3] * 65536 + e.receivedata[4] * 256 + e.receivedata[5] * 16).toDouble();
                                          double toc = (tout - 1677722) * 200 / 13421772 - 50;

                                          transdata = Pbar.toStringAsFixed(3) + 'Bar ,' + toc.toStringAsFixed(3) + 'oC';
                                        } catch (e) {
                                          transdata = 'Erro';
                                        }

                                        break;
                                      }
                                  }

                                  return Card(
                                    child: ListTile(
                                      title: Text('${e.receivedata}' + '\n' + transdata),
                                      subtitle: Text(e.receivetime),
                                    ),
                                  );
                                }).toList(),
                              ))
                          .toList()))
            ]),
            bottomNavigationBar: Material(
              color: Theme.of(context).primaryColor,
              child: TabBar(
                  indicatorColor: Colors.red,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.white,
                  isScrollable: true,
                  tabs: devicenamelist.keys.map((e) {
                    return Tab(child: Text(devicenamelist[e]!));
                  }).toList()),
            )));

    // return StreamBuilder<List<BluetoothDevice>>(
    //     stream: Stream.periodic(const Duration(seconds: 1)).asyncMap((_) => FlutterBlue.instance.connectedDevices),
    //     initialData: [],
    //     builder: (c, snapdevice) {
    //       if (snapdevice.data!.isNotEmpty) {
    //         try {
    //           tabController = TabController(length: snapdevice.data!.length, vsync: this, initialIndex: deviceindex);
    //           device = snapdevice.data![deviceindex];
    //           tabController!.addListener(() {
    //             if (tabController!.indexIsChanging) {
    //               setState(() {
    //                 deviceindex = tabController!.index;
    //               });
    //             }
    //           });
    //         } catch (e) {}
    //
    //         return Scaffold(
    //             appBar: AppBar(
    //               title: Text('模式:' + features[mode]),
    //               actions: [
    //                 IconButton(
    //                     onPressed: () {
    //                       Navigator.push(
    //                         //從登入push到第二個
    //                         context,
    //                         MaterialPageRoute(builder: (context) => scanpage()),
    //                       ).then((value) => setState(() {
    //                             deviceindex = 0;
    //                           }));
    //                     },
    //                     icon: const Icon(Icons.search)),
    //                 PopupMenuButton(
    //                   icon: Icon(Icons.more_vert),
    //                   itemBuilder: (BuildContext context) => <PopupMenuEntry>[
    //                     PopupMenuItem(
    //                       child: ListTile(
    //                         onTap: () {
    //                           Navigator.pop(context);
    //                           setState(() {
    //                             mode = 0;
    //                           });
    //                         },
    //                         title: Text('Terminal'),
    //                       ),
    //                     ),
    //                     PopupMenuItem(
    //                       child: ListTile(
    //                         onTap: () {
    //                           Navigator.pop(context);
    //                           setState(() {
    //                             mode = 1;
    //                           });
    //                         },
    //                         title: Text('Demo溫度'),
    //                       ),
    //                     ),
    //                     PopupMenuItem(
    //                       child: ListTile(
    //                         onTap: () {
    //                           Navigator.pop(context);
    //                           setState(() {
    //                             mode = 2;
    //                           });
    //                         },
    //                         title: Text('MPR-25PA-1AB'),
    //                       ),
    //                     ),
    //                     PopupMenuItem(
    //
    //                       child: ListTile(
    //                         onTap: () {
    //                           Navigator.pop(context);
    //                           setState(() {
    //                             mode = 3;
    //                           });
    //                         },
    //                         title: Text('ABP2-010BG-2A3xx'),
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ],
    //             ),
    //             body: SingleChildScrollView(
    //               child: Column(
    //                 children: <Widget>[
    //                   StreamBuilder<BluetoothDeviceState>(
    //                       stream: device!.state,
    //                       initialData: BluetoothDeviceState.connecting,
    //                       builder: (c, snapstate) {
    //                         switch (snapstate.data) {
    //                           case (BluetoothDeviceState.connected):
    //                             {
    //                               discoverservice(device);
    //
    //                               break;
    //                             }
    //                           case (BluetoothDeviceState.disconnected):
    //                             {
    //                               if (btdataList.keys.contains(device!.id.id)) {
    //                                 btdataList.remove(device!.id.id);
    //                                 Subscriptions[device!.id.id]!.cancel();
    //                                 Subscriptions.remove(device!.id.id);
    //                               }
    //
    //                               break;
    //                             }
    //                         }
    //
    //                         return Column(children: [
    //                           ListTile(
    //                             leading: Icon(snapstate.data == BluetoothDeviceState.connected ? Icons.bluetooth_connected : Icons.bluetooth_disabled),
    //                             title: Text(device!.name + '${snapstate.data.toString().split('.')[1]}.'),
    //                             subtitle: Text('${device!.id}'),
    //                           ),
    //                           btdataList.keys.contains(device!.id.id)
    //                               ? SingleChildScrollView(
    //                                   child: SizedBox(
    //                                     height: 700,
    //                                     child: ListView(
    //                                       shrinkWrap: true,
    //                                       children: btdataList[device!.id.id]!.map((e) {
    //                                         String transdata = '';
    //                                         switch (mode) {
    //                                           case (0):
    //                                             {
    //                                               transdata = latin1.decode(e.receivedata).trim();
    //                                               break;
    //                                             }
    //                                           case (1):
    //                                             {
    //                                               try {
    //                                                 double c = (e.receivedata[0] - 32) * 5 / 9;
    //                                                 transdata = e.receivedata[0].toString() + 'f , ' + c.toStringAsFixed(2) + 'c';
    //                                               } catch (e) {
    //                                                 transdata = '格式錯誤 無法轉換';
    //                                               }
    //
    //                                               break;
    //                                             }
    //                                           case (2):
    //                                             {
    //                                               try {
    //                                                 double out = (e.receivedata[0] * 65536 + e.receivedata[1] * 256 + e.receivedata[2] * 16).toDouble();
    //                                                 double tout = (out - 1677722) * 25 / 13421772;
    //
    //                                                 transdata = tout.toStringAsFixed(3) + 'PSI';
    //                                               } catch (e) {
    //                                                 transdata = '格式錯誤 無法轉換';
    //                                               }
    //
    //                                               break;
    //                                             }
    //                                           case (3):
    //                                             {
    //                                               try {
    //                                                 double pout = (e.receivedata[0] * 65536 + e.receivedata[1] * 256 + e.receivedata[2] * 16).toDouble();
    //                                                 double Pbar = (pout - 1677722) * 10 / 13421772;
    //
    //                                                 double tout = (e.receivedata[3] * 65536 + e.receivedata[4] * 256 + e.receivedata[5] * 16).toDouble();
    //                                                 double toc = (tout - 1677722) * 200 / 13421772 - 50;
    //
    //                                                 transdata = Pbar.toStringAsFixed(3) + 'Bar ,' + toc.toStringAsFixed(3) + 'oC';
    //                                               } catch (e) {
    //                                                 transdata = '格式錯誤 無法轉換';
    //                                               }
    //
    //                                               break;
    //                                             }
    //                                         }
    //
    //                                         return Card(
    //                                           child: ListTile(
    //                                             title: Text('${e.receivedata}' + '\n' + transdata),
    //                                             subtitle: Text(e.receivetime),
    //                                           ),
    //                                         );
    //                                       }).toList(),
    //                                     ),
    //                                   ),
    //                                 )
    //                               : Container()
    //                         ]);
    //                       }),
    //                 ],
    //               ),
    //             ),
    //             bottomNavigationBar: Material(
    //                 color: Theme.of(context).primaryColor,
    //                 child: TabBar(
    //                     controller: tabController,
    //                     indicatorColor: Colors.red,
    //                     labelColor: Colors.black,
    //                     unselectedLabelColor: Colors.white,
    //                     isScrollable: true,
    //                     tabs: snapdevice.data!
    //                         .map(
    //                           (e) => SizedBox(
    //                             child: Tab(
    //                               child: StreamBuilder<BluetoothDeviceState>(
    //                                 stream: e.state,
    //                                 initialData: BluetoothDeviceState.connecting,
    //                                 builder: (c, state) {
    //                                   return Text(e.name + '${state.data.toString().split('.')[1]}.');
    //                                 },
    //                               ),
    //                             ),
    //                           ),
    //                         )
    //                         .toList())));
    //       } else {
    //         return Scaffold(
    //           appBar: AppBar(
    //             title: Text('模式:' + features[mode]),
    //             actions: [
    //               IconButton(
    //                   onPressed: () {
    //                     Navigator.push(
    //                       //從登入push到第二個
    //                       context,
    //                       MaterialPageRoute(builder: (context) => scanpage()),
    //                     ).then((value) => setState(() {
    //                           deviceindex = 0;
    //                         }));
    //                   },
    //                   icon: const Icon(Icons.search)),
    //             ],
    //           ),
    //           body: Center(
    //             child: Column(
    //               mainAxisSize: MainAxisSize.min,
    //               children: const <Widget>[
    //                 Text(
    //                   '尚未取得任何裝置',
    //                 ),
    //               ],
    //             ),
    //           ),
    //         );
    //       }
    //     });
  }

  Future<void> discoverservice(BluetoothDevice? device) async {
    if (!devicenamelist.keys.contains(device!.id.id)) {
      await device!.discoverServices().then((servicelist) async {
        BluetoothService service = servicelist.singleWhere((e) => e.uuid.toString() == '0000ffe0-0000-1000-8000-00805f9b34fb');
        BluetoothCharacteristic chara = service.characteristics.singleWhere((e) => e.uuid.toString() == '0000ffe1-0000-1000-8000-00805f9b34fb');
        try {
          await chara.setNotifyValue(true);
          devicenamelist[device.id.id] = device.name;
          btdataList[device.id.id] = [];
          Subscriptions[device.id.id] = chara.value.listen((event) {
            if (event.isNotEmpty) {
              setState(() {
                btdataList[device!.id.id]!.insert(0, btdata(event));
              });
            }
          });
        } catch (e) {
          var a = 0;
        }
      });
    }
  }
}

class subscriptiondata {
  StreamSubscription subscription;
  List<btdata> datalist;

  subscriptiondata(this.subscription, this.datalist);
}

class btdata {
  String receivetime = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
  List<int> receivedata;

  btdata(this.receivedata);
}
