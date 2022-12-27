import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class SecondRoute extends StatefulWidget {
  SecondRoute({super.key});


  @override
  State<SecondRoute> createState() => _SecondRouteState();
}

class _SecondRouteState extends State<SecondRoute> with WidgetsBindingObserver {
  String counterKey = 'home_counter';

  // String date = DateTime.now().toString();
  String date = DateFormat("dd-MM-yyyy").format(DateTime.now());
  String time = DateFormat("hh:mm:ss a").format(DateTime.now());

  // String formattedDate = DateFormat('kk:mm:ss \n EEE d MMM').format(now);
  int _counter = 0;
  List<String> list = [];


  void _getHistoryListFromHive() {
    final box = Hive.box<dynamic>('mybox');
    list = box.get(counterKey) ?? [];
    print("counter value $list");
    // _counter = value;
    // List toDoList = [];

    setState(() {
      _counter++;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    print("mounika applications closed");
    if (state == AppLifecycleState.paused) {
      final box = Hive.box<dynamic>('mybox');
      list.add("$_counter $date $time");

      box.put(counterKey, list);
      // if (!mounted)
      //   setState(() {
      //     _counter = 0;
      //   });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    _getHistoryListFromHive();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff3D345F),
        title: const Text('History'),
      ),
      body: ListView.builder(
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              leading: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(list[index].split(" ")[1],
                    style: const TextStyle(color: Colors.grey, fontSize: 17)),
              ),
              trailing: Text(list[index].split(" ")[2],
                  style: const TextStyle(color: Colors.grey, fontSize: 17)),
              title: Text(' Beads ${list[index].split(" ")[0]}',
                  style: const TextStyle(fontSize: 17)),
            );
          }),

      // ListTile(
      //   leading: Padding(
      //     padding: const EdgeInsets.all(4.0),
      //     child: Text(date,style: const TextStyle(color: Colors.grey,fontSize: 17)),
      //   ),
      //   trailing: Text(time, style: const TextStyle(color: Colors.grey,fontSize: 17)),
      //   title: Text(' Beads  $value',
      //       style: const TextStyle(fontSize: 17)),
      // ),

      // Center(
      //   child: ElevatedButton(
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //     child: const Text('Go back!'),
      //   ),
      // ),
    );
  }
}
