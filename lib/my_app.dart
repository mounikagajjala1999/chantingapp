import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:yt_counter/ui/home_page.dart';

import 'main.dart';
import 'chanting/api.dart';
import 'chanting/model.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ui',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ), // ThemeData
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    ); // MaterialApp
  }
}
