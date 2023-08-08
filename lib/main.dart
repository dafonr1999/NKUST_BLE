import 'package:flutter/material.dart';
import 'package:nkust_ble/BLE_controlpanel.dart';
import 'package:nkust_ble/scanpage.dart';
import 'package:nkust_ble/userinfo.dart';
import 'global.dart' as GV;
import 'multipleterminal.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WNMC_BLE',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Electric Vehicle Operation and Maintenance Training Course'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Future<dynamic>callapi ()async{

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, childAspectRatio: 2.5),
          itemCount: GV.arr.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              child: Card(
                color: Colors.amber,
                child: Center(child: Text(GV.arr[index])),
              ),
              onTap: () {
                switch (index) {
                  case(0):{
                    {
                      Navigator.push(
                        //從登入push到第二個
                        context,
                        MaterialPageRoute(builder: (context) => terminal()),
                      );
                      break;
                    }
                    break;

                  }
                  case (4):
                    {
                      Navigator.push(
                        //從登入push到第二個
                        context,
                        MaterialPageRoute(builder: (context) => userinfo()),
                      );
                      break;
                    }
                  case (5):
                    {
                      break;
                    }
                  default:{
                    GV.receivemode = index;
                    Navigator.push(
                      //從登入push到第二個
                      context,
                      MaterialPageRoute(builder: (context) => scanpage()),
                    );
                    break;
                  }
                }
              },
            );
          }),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
