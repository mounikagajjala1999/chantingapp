import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:yt_counter/ui/histroy_page.dart';

import '../streams/total_count_stream.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  var version;
  var err=0;
  var count=0;



  Future<void> getVersion(String v) async {
    await coutStream.count.listen((event) {
      _increment();
      print(">>>>123<<<>>$event");

      setState(() {

        version = v;
        err = event;
        print(err);
      });
    });
  }
  void _increment() {

    setState(() {
      if (err % 108 == 0 && err != 0) {
        count++;
        print(" shifaaaaa$count");
      }
      // count++;
    });
  }
  @override
  void initState() {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      String version = packageInfo.version;
      print("version =" + version);
      getVersion(version);
    });

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String counterKey = 'home_counter';
    Size size = MediaQuery.of(context).size;
    final box = Hive.box<dynamic>('mybox');
    List<String> list = box.get(counterKey) ?? [];

    return Drawer(
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(0),
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xff3D345F), Color(0xffE79997)])),
            //BoxDecoration
            child: UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.transparent),
              accountName: SizedBox(
                height: 60,
                child: Column(
                  children: [
                    Text(
                      "Chanting App ",
                      style: TextStyle(fontSize: 18),
                    ),
                    Spacer(),
                    Text(
                      "Total count ${count}.${err.toString()}",
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
              currentAccountPictureSize: Size.square(50),
              currentAccountPicture: ClipRRect(
                child: Image(
                  image: AssetImage("assets/image/chantingapplogo.png"),
                ),
              ),
              accountEmail: null, //circleAvatar
            ),
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text(' History ', style: TextStyle(fontSize: 20)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryPage()),
              );
            },
          ),
          const AboutListTile(
            aboutBoxChildren: [
              Text(
                  "Chanting app its a Meditation app (previously Chanting Monitor) is a new,"
                  " comfortable and simple meditation assistant right on your phone. "
                  "It provides an authentic, simple and the most powerful meditation for the modern age.")
            ],
            applicationName: "Chanting app",
            icon: Icon(
              Icons.info,
            ),
            applicationIcon: Icon(
              Icons.local_activity_outlined,
            ),
            child: Text('About app', style: TextStyle(fontSize: 17)),
          ),
          SizedBox(
            height: size.height / 1.8,
            child: Container(
              // color: Colors.amber,
              alignment: Alignment.bottomCenter,
              child: Text("version-$version",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.grey, fontStyle: FontStyle.italic)),
            ),
          )
        ],
      ),
    );
  }
}
