import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';

int _counter = 0;
int timerstarted = 0;
String sreturn = 'no scan';
String addition_string = '';
Uint8List _rawblescanningdata = Uint8List(pac_size*sensors_num+1);

int sensors_num = 16;
int pac_size = 31;
int columns_number = 6;

var b_data_previous = ByteData(pac_size*sensors_num+1);

var _data_s_num = 0;
var _data_rssi = 0;
var _data_alarm = 0;
var _data_temp = 0.0;
var _data_hum = 0.0;
var _data_vbat = 0.0;
final s_sensors = List<String>.filled(sensors_num * columns_number, '');
TextStyle textStyle =  TextStyle(inherit: true,  color: Colors.blue[900], fontWeight: FontWeight.bold);
final textStyle_list = List<TextStyle>.filled(sensors_num * columns_number, textStyle);

void main() {
  var message = "Hello, flutter app is starting!";
  debugPrint(message);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Sensors'),
    );
  }

}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


/***************************************** Android native BLE scanning start1 ***********************************/
/*
  static const platform = MethodChannel('samples.flutter.dev/ble_scanning'); // get raw ble scanning data

// scanning data.
  String _rawblescanningdata = '';
  Future<void> _get_raw_ble_scanning_data() async {
    String raw_ble_scanning_data = '';
    try {
      final result = await platform.invokeMethod<String>('get_raw_scanning_data');
      raw_ble_scanning_data = result!;
    } on PlatformException catch (e) {
      debugPrint("Error from get_raw_scanning_data native function");
    }

    setState(() {
      _rawblescanningdata = raw_ble_scanning_data;
      addition_string = _rawblescanningdata;
    });
  }
*/


  static const platform = MethodChannel('samples.flutter.dev/ble_scanning'); // get raw ble scanning data

// scanning data.
  //Uint8List _rawblescanningdata = Uint8List.fromList([0]);
  Future<void> _get_raw_ble_scanning_data() async {
    Uint8List raw_ble_scanning_data = Uint8List.fromList([0]);
    try {
      final result = await platform.invokeMethod<Uint8List>('get_raw_scanning_data');
      raw_ble_scanning_data = result!;
      _rawblescanningdata = raw_ble_scanning_data;
    } on PlatformException catch (e) {
      debugPrint("Error from get_raw_scanning_data native function");
    }

    setState(() {

    });
  }
/***************************************** Android native BLE scanning end1 ***********************************/

  String s_0 = "\r\n";
  String s_1 = " SN: sensor's number";
  String s_2 = " RSSI: received signal strength indication";
  String s_3 = " ACC_al: accelerometer alarm";
  String s_4 = " T: temperature";
  String s_5 = " H: humidity";
  String s_6 = " Vbat: battery voltage";
  String s_7 = " Blue: value has changed";

  String s_8 = "You have pushed the button this  times: ";

  void scanDevices() async {
    _get_raw_ble_scanning_data();
    debugPrint('message ${_counter++}');

    var b_data = ByteData.sublistView(_rawblescanningdata);
    var text_style_val_not_changed = TextStyle(inherit: false,  color: Colors.blue[900], fontWeight: FontWeight.bold);
    var text_style_val_changed = TextStyle(inherit: false,  color: Colors.blue[300], fontWeight: FontWeight.bold);


    for(int h = 0; h < sensors_num; h++) {
      if ((_rawblescanningdata[h * pac_size] == 25)
          && (_rawblescanningdata[h * pac_size + 2] == 7)
          && (_rawblescanningdata[h * pac_size + 1] >= 0)
          && (_rawblescanningdata[h * pac_size + 2] < 16)) {
        _data_s_num = b_data.getInt8(h * pac_size + 1);
        _data_rssi = b_data.getInt8(h * pac_size + 3);
        _data_alarm = b_data.getInt16(h * pac_size + 4, Endian.little);
        _data_temp = b_data.getFloat32(h * pac_size + 14, Endian.little);
        _data_hum = b_data.getFloat32(h * pac_size + 18, Endian.little);
        _data_vbat = b_data.getFloat32(h * pac_size + 22, Endian.little) / 1000;
      }else {
        _data_s_num = 0;
        _data_rssi = 0;
        _data_alarm = 0;
        _data_temp = 0.0;
        _data_hum = 0.0;
        _data_vbat = 0.0;
      }

        var y =  h * columns_number;

        s_sensors[y + 0] = h.toString();
        textStyle_list[y+0] = text_style_val_not_changed;


        s_sensors[y + 1] = _data_rssi.toString();
        if(s_sensors[y + 1] == (b_data_previous.getInt8(h * pac_size + 3)).toString())
        {
          textStyle_list[y+1] = text_style_val_not_changed;
        }
        else
        {
          textStyle_list[y+1] = text_style_val_changed;
        }

        s_sensors[y + 2] = _data_alarm.toString();
        if(s_sensors[y + 2] == (b_data_previous.getInt16(h * pac_size + 4, Endian.little)).toString())
        {
          textStyle_list[y+2] = text_style_val_not_changed;
        }
        else
        {
          textStyle_list[y+2] = text_style_val_changed;
        }

        s_sensors[y + 3] = _data_temp.toStringAsFixed(2);
        if(s_sensors[y + 3]  == (b_data_previous.getFloat32(h * pac_size + 14, Endian.little)).toStringAsFixed(2))
        {
          textStyle_list[y+3] = text_style_val_not_changed;
        }
        else
        {
          textStyle_list[y+3] = text_style_val_changed;
        }

        s_sensors[y + 4] = _data_hum.toStringAsFixed(2);
        if(s_sensors[y + 4] == (b_data_previous.getFloat32(h * pac_size + 18, Endian.little)).toStringAsFixed(2))
        {
          textStyle_list[y+4] = text_style_val_not_changed;
        }
        else
        {
          textStyle_list[y+4] = text_style_val_changed;
        }

        s_sensors[y + 5] = _data_vbat.toStringAsFixed(2);
        if(s_sensors[y + 5] == (b_data_previous.getFloat32(h * pac_size +  22, Endian.little) / 1000).toStringAsFixed(2))
        {
          textStyle_list[y+5] = text_style_val_not_changed;
        }
        else
        {
          textStyle_list[y+5] = text_style_val_changed;
        }
    }
    b_data_previous = b_data;

    setState(() {
      textStyle_list;
      s_sensors;
      _counter;
    });
   }



  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void startTimer() async
  {
    if (timerstarted == 0) {
      Timer.periodic(
          const Duration(seconds: 5), (Timer timer) => scanDevices());
      timerstarted = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    startTimer();
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 500,
              height: 150,
              color: Colors.blue[100],
              alignment: Alignment.topLeft,
            child: Text(s_1+s_0+s_2+s_0+s_3+s_0+s_4+s_0+s_5+s_0+s_6+s_0+s_7, textAlign: TextAlign.start),
            ),

            Container(
                width: 400,
                height: 400,
                color: Colors.grey[100],
                alignment: Alignment.topLeft,
                child: DataTable(
                    columns: const [
                      DataColumn(
                        label: Text('S_N'),
                      ),
                      DataColumn(
                        label: Text('RSSI'),
                      ),
                      DataColumn(
                        label: Text('ALARM'),
                      ),
                      DataColumn(
                        label: Text('TEMP'),
                      ),
                      DataColumn(
                        label: Text('HUM'),
                      ),
                      DataColumn(
                        label: Text('VBAT'),
                      ),
                    ],
                    rows: [

                      DataRow(cells: [
                        DataCell(Text(s_sensors[0*columns_number + 0], style: textStyle_list[0*columns_number + 0])),
                        DataCell(Text(s_sensors[0*columns_number + 1], style: textStyle_list[0*columns_number + 1])),
                        DataCell(Text(s_sensors[0*columns_number + 2], style: textStyle_list[0*columns_number + 2])),
                        DataCell(Text(s_sensors[0*columns_number + 3], style: textStyle_list[0*columns_number + 3])),
                        DataCell(Text(s_sensors[0*columns_number + 4], style: textStyle_list[0*columns_number + 4])),
                        DataCell(Text(s_sensors[0*columns_number + 5], style: textStyle_list[0*columns_number + 5])),
                      ]),

                      DataRow(cells: [
                        DataCell(Text(s_sensors[1*columns_number + 0], style: textStyle_list[1*columns_number + 0])),
                        DataCell(Text(s_sensors[1*columns_number + 1], style: textStyle_list[1*columns_number + 1])),
                        DataCell(Text(s_sensors[1*columns_number + 2], style: textStyle_list[1*columns_number + 2])),
                        DataCell(Text(s_sensors[1*columns_number + 3], style: textStyle_list[1*columns_number + 3])),
                        DataCell(Text(s_sensors[1*columns_number + 4], style: textStyle_list[1*columns_number + 4])),
                        DataCell(Text(s_sensors[1*columns_number + 5], style: textStyle_list[1*columns_number + 5])),
                      ]),

                      DataRow(cells: [
                        DataCell(Text(s_sensors[2*columns_number + 0], style: textStyle_list[2*columns_number + 0])),
                        DataCell(Text(s_sensors[2*columns_number + 1], style: textStyle_list[2*columns_number + 1])),
                        DataCell(Text(s_sensors[2*columns_number + 2], style: textStyle_list[2*columns_number + 2])),
                        DataCell(Text(s_sensors[2*columns_number + 3], style: textStyle_list[2*columns_number + 3])),
                        DataCell(Text(s_sensors[2*columns_number + 4], style: textStyle_list[2*columns_number + 4])),
                        DataCell(Text(s_sensors[2*columns_number + 5], style: textStyle_list[2*columns_number + 5])),
                      ]),

                      DataRow(cells: [
                        DataCell(Text(s_sensors[3*columns_number + 0], style: textStyle_list[3*columns_number + 0])),
                        DataCell(Text(s_sensors[3*columns_number + 1], style: textStyle_list[3*columns_number + 1])),
                        DataCell(Text(s_sensors[3*columns_number + 2], style: textStyle_list[3*columns_number + 2])),
                        DataCell(Text(s_sensors[3*columns_number + 3], style: textStyle_list[3*columns_number + 3])),
                        DataCell(Text(s_sensors[3*columns_number + 4], style: textStyle_list[3*columns_number + 4])),
                        DataCell(Text(s_sensors[3*columns_number + 5], style: textStyle_list[3*columns_number + 5])),
                      ]),

                      DataRow(cells: [
                        DataCell(Text(s_sensors[4*columns_number + 0], style: textStyle_list[4*columns_number + 0])),
                        DataCell(Text(s_sensors[4*columns_number + 1], style: textStyle_list[4*columns_number + 1])),
                        DataCell(Text(s_sensors[4*columns_number + 2], style: textStyle_list[4*columns_number + 2])),
                        DataCell(Text(s_sensors[4*columns_number + 3], style: textStyle_list[4*columns_number + 3])),
                        DataCell(Text(s_sensors[4*columns_number + 4], style: textStyle_list[4*columns_number + 4])),
                        DataCell(Text(s_sensors[4*columns_number + 5], style: textStyle_list[4*columns_number + 5])),
                      ]),

                      DataRow(cells: [
                        DataCell(Text(s_sensors[5*columns_number + 0], style: textStyle_list[5*columns_number + 0])),
                        DataCell(Text(s_sensors[5*columns_number + 1], style: textStyle_list[5*columns_number + 1])),
                        DataCell(Text(s_sensors[5*columns_number + 2], style: textStyle_list[5*columns_number + 2])),
                        DataCell(Text(s_sensors[5*columns_number + 3], style: textStyle_list[5*columns_number + 3])),
                        DataCell(Text(s_sensors[5*columns_number + 4], style: textStyle_list[5*columns_number + 4])),
                        DataCell(Text(s_sensors[5*columns_number + 5], style: textStyle_list[5*columns_number + 5])),
                      ]),

                      DataRow(cells: [
                        DataCell(Text(s_sensors[6*columns_number + 0], style: textStyle_list[6*columns_number + 0])),
                        DataCell(Text(s_sensors[6*columns_number + 1], style: textStyle_list[6*columns_number + 1])),
                        DataCell(Text(s_sensors[6*columns_number + 2], style: textStyle_list[6*columns_number + 2])),
                        DataCell(Text(s_sensors[6*columns_number + 3], style: textStyle_list[6*columns_number + 3])),
                        DataCell(Text(s_sensors[6*columns_number + 4], style: textStyle_list[6*columns_number + 4])),
                        DataCell(Text(s_sensors[6*columns_number + 5], style: textStyle_list[6*columns_number + 5])),
                      ]),

                      DataRow(cells: [
                        DataCell(Text(s_sensors[7*columns_number + 0], style: textStyle_list[7*columns_number + 0])),
                        DataCell(Text(s_sensors[7*columns_number + 1], style: textStyle_list[7*columns_number + 1])),
                        DataCell(Text(s_sensors[7*columns_number + 2], style: textStyle_list[7*columns_number + 2])),
                        DataCell(Text(s_sensors[7*columns_number + 3], style: textStyle_list[7*columns_number + 3])),
                        DataCell(Text(s_sensors[7*columns_number + 4], style: textStyle_list[7*columns_number + 4])),
                        DataCell(Text(s_sensors[7*columns_number + 5], style: textStyle_list[7*columns_number + 5])),
                      ]),

                      DataRow(cells: [
                        DataCell(Text(s_sensors[8*columns_number + 0], style: textStyle_list[8*columns_number + 0])),
                        DataCell(Text(s_sensors[8*columns_number + 1], style: textStyle_list[8*columns_number + 1])),
                        DataCell(Text(s_sensors[8*columns_number + 2], style: textStyle_list[8*columns_number + 2])),
                        DataCell(Text(s_sensors[8*columns_number + 3], style: textStyle_list[8*columns_number + 3])),
                        DataCell(Text(s_sensors[8*columns_number + 4], style: textStyle_list[8*columns_number + 4])),
                        DataCell(Text(s_sensors[8*columns_number + 5], style: textStyle_list[8*columns_number + 5])),
                      ]),

                      DataRow(cells: [
                        DataCell(Text(s_sensors[9*columns_number + 0], style: textStyle_list[9*columns_number + 0])),
                        DataCell(Text(s_sensors[9*columns_number + 1], style: textStyle_list[9*columns_number + 1])),
                        DataCell(Text(s_sensors[9*columns_number + 2], style: textStyle_list[9*columns_number + 2])),
                        DataCell(Text(s_sensors[9*columns_number + 3], style: textStyle_list[9*columns_number + 3])),
                        DataCell(Text(s_sensors[9*columns_number + 4], style: textStyle_list[9*columns_number + 4])),
                        DataCell(Text(s_sensors[9*columns_number + 5], style: textStyle_list[9*columns_number + 5])),
                      ]),

                      DataRow(cells: [
                        DataCell(Text(s_sensors[10*columns_number + 0], style: textStyle_list[10*columns_number + 0])),
                        DataCell(Text(s_sensors[10*columns_number + 1], style: textStyle_list[10*columns_number + 1])),
                        DataCell(Text(s_sensors[10*columns_number + 2], style: textStyle_list[10*columns_number + 2])),
                        DataCell(Text(s_sensors[10*columns_number + 3], style: textStyle_list[10*columns_number + 3])),
                        DataCell(Text(s_sensors[10*columns_number + 4], style: textStyle_list[10*columns_number + 4])),
                        DataCell(Text(s_sensors[10*columns_number + 5], style: textStyle_list[10*columns_number + 5])),
                      ]),

                      DataRow(cells: [
                        DataCell(Text(s_sensors[11*columns_number + 0], style: textStyle_list[11*columns_number + 0])),
                        DataCell(Text(s_sensors[11*columns_number + 1], style: textStyle_list[11*columns_number + 1])),
                        DataCell(Text(s_sensors[11*columns_number + 2], style: textStyle_list[11*columns_number + 2])),
                        DataCell(Text(s_sensors[11*columns_number + 3], style: textStyle_list[11*columns_number + 3])),
                        DataCell(Text(s_sensors[11*columns_number + 4], style: textStyle_list[11*columns_number + 4])),
                        DataCell(Text(s_sensors[11*columns_number + 5], style: textStyle_list[11*columns_number + 5])),
                      ]),

                      DataRow(cells: [
                        DataCell(Text(s_sensors[12*columns_number + 0], style: textStyle_list[12*columns_number + 0])),
                        DataCell(Text(s_sensors[12*columns_number + 1], style: textStyle_list[12*columns_number + 1])),
                        DataCell(Text(s_sensors[12*columns_number + 2], style: textStyle_list[12*columns_number + 2])),
                        DataCell(Text(s_sensors[12*columns_number + 3], style: textStyle_list[12*columns_number + 3])),
                        DataCell(Text(s_sensors[12*columns_number + 4], style: textStyle_list[12*columns_number + 4])),
                        DataCell(Text(s_sensors[12*columns_number + 5], style: textStyle_list[12*columns_number + 5])),
                      ]),

                      DataRow(cells: [
                        DataCell(Text(s_sensors[13*columns_number + 0], style: textStyle_list[13*columns_number + 0])),
                        DataCell(Text(s_sensors[13*columns_number + 1], style: textStyle_list[13*columns_number + 1])),
                        DataCell(Text(s_sensors[13*columns_number + 2], style: textStyle_list[13*columns_number + 2])),
                        DataCell(Text(s_sensors[13*columns_number + 3], style: textStyle_list[13*columns_number + 3])),
                        DataCell(Text(s_sensors[13*columns_number + 4], style: textStyle_list[13*columns_number + 4])),
                        DataCell(Text(s_sensors[13*columns_number + 5], style: textStyle_list[13*columns_number + 5])),
                      ]),

                      DataRow(cells: [
                        DataCell(Text(s_sensors[14*columns_number + 0], style: textStyle_list[14*columns_number + 0])),
                        DataCell(Text(s_sensors[14*columns_number + 1], style: textStyle_list[14*columns_number + 1])),
                        DataCell(Text(s_sensors[14*columns_number + 2], style: textStyle_list[14*columns_number + 2])),
                        DataCell(Text(s_sensors[14*columns_number + 3], style: textStyle_list[14*columns_number + 3])),
                        DataCell(Text(s_sensors[14*columns_number + 4], style: textStyle_list[14*columns_number + 4])),
                        DataCell(Text(s_sensors[14*columns_number + 5], style: textStyle_list[14*columns_number + 5])),
                      ]),

                      DataRow(cells: [
                        DataCell(Text(s_sensors[15*columns_number + 0], style: textStyle_list[15*columns_number + 0])),
                        DataCell(Text(s_sensors[15*columns_number + 1], style: textStyle_list[15*columns_number + 1])),
                        DataCell(Text(s_sensors[15*columns_number + 2], style: textStyle_list[15*columns_number + 2])),
                        DataCell(Text(s_sensors[15*columns_number + 3], style: textStyle_list[15*columns_number + 3])),
                        DataCell(Text(s_sensors[15*columns_number + 4], style: textStyle_list[15*columns_number + 4])),
                        DataCell(Text(s_sensors[15*columns_number + 5], style: textStyle_list[15*columns_number + 5])),
                      ]),



                    ],
                dataRowHeight: 20,
                headingRowHeight: 50,
                columnSpacing: 20,)
            ),
            Container(
              width: 500,
              height: 50,
              color: Colors.blue[100],
              alignment: Alignment.center,
              child: Text(
                'iteration: $_counter',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
