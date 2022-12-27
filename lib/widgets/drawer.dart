import 'package:flutter/material.dart';
import 'package:yt_counter/ui/histroy_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xff3D345F), Color(0xffE79997)])),
            //BoxDecoration
            child: Text(""),
          ),
          ListTile(
            leading: Icon(Icons.ac_unit),
            title: Text(' History ', style: TextStyle(fontSize: 20)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryPage()),
              );
            },
            // trailing: Icon(Icons.ac_unit),
          ),
          // ListTile(
          //   leading: Icon(Icons.history),
          //   title: Column(
          //     mainAxisAlignment: MainAxisAlignment.start,
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Text('Recent count   $value',
          //           style: TextStyle(fontSize: 17)),
          //       Text(date, style: TextStyle(color: Colors.grey)),
          //     ],
          //   ),
          // ),
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

          // Padding(
          //   padding: const EdgeInsets.only(left: 170,right: 10),
          //   child: MaterialButton(
          //     color: Color(0xffB0818E),
          //     shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(14)),
          //     child: Text(
          //       'Reset',
          //       style: TextStyle(
          //           fontSize: size.width / 25,
          //           color: Colors.white,
          //           fontFamily:
          //           "assets/fonts/Poppins/Poppins-Regular.ttf",
          //           ),
          //     ),
          //     onPressed: () {
          //
          //       box.clear();
          //       _clear();
          //
          //     },
          //
          //   ),
          // ),
        ],
      ),
    );
  }
}
