import 'package:flutter/material.dart';

class MyAppBarWidget extends StatelessWidget {
  const MyAppBarWidget({Key? key, required this.drawerscaffoldkey})
      : super(key: key);
  final GlobalKey<ScaffoldState> drawerscaffoldkey;


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height / 9,
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              //on drawer menu pressed
              if (drawerscaffoldkey.currentState!.isDrawerOpen) {
                //if drawer is open, then close the drawer
                Navigator.pop(context);
              } else {
                drawerscaffoldkey.currentState!.openDrawer();
                //if drawer is closed then open the drawer.
              }
            },
            icon: const Icon(Icons.menu, color: Colors.white, size: 23),
          ),
          Container(
            alignment: Alignment.topLeft,
            padding: (EdgeInsets.only(top: 30, bottom: 30, left: 7)),
            // color: Colors.blue,
            child: Center(
              child: LayoutBuilder(builder: (context, constraints) {
                var hour = DateTime.now().hour;
                var min = DateTime.now().minute;
                // print(hour);
                if (hour < 12) {
                  return Text(
                    "Good Morning",
                    style: TextStyle(
                        fontFamily: "Noto_Sans",
                        fontSize: size.width / 16,
                        color: Colors.white,
                        // fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none),
                    textAlign: TextAlign.start,
                  );
                } else if (hour >= 12 && hour < 16) {
                  return Text(
                    "Good Afternoon",
                    style: TextStyle(
                        fontFamily: "Noto_Sans",
                        fontSize: size.width / 16,
                        color: Colors.white,
                        // fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none),
                    textAlign: TextAlign.start,
                  );
                } else if ((hour >= 16) && (hour < 19)) {
                  return Text(
                    "Good Evening",
                    style: TextStyle(
                        fontFamily: "Noto_Sans",
                        fontSize: size.width / 16,
                        color: Colors.white,
                        // fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none),
                    textAlign: TextAlign.start,
                  );
                } else {
                  return Text(
                    "Good Night",
                    style: TextStyle(
                        fontFamily: "Noto_Sans",
                        fontSize: size.width / 16,
                        color: Colors.white,
                        // fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none),
                    textAlign: TextAlign.start,
                  );
                }
              }),
            ),
          ),
        ],
      ),
    );
  }
}
