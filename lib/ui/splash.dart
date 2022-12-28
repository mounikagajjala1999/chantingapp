import 'package:flutter/material.dart';

import 'home_page.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _navigatetohome();
  }

  _navigatetohome() async {
    await Future.delayed(Duration(milliseconds: 2000), () {});
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => MyHomePage()));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var asset1 = "assets/image/chant.png";
    return Stack(
      children: [
        Container(
            height: size.height,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xff3D345F), Color(0xffE79997)]))),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Container(
              child: Image.asset(
                asset1,
                height: size.height / 4,
                fit: BoxFit.cover,
              ),

              // Text("splash screen",style: TextStyle(
              //   fontSize: 24,
              //   fontWeight: FontWeight.bold
              // ),),
            ),
          ),
        ),

      ],
    );
  }
}
