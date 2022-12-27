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

import '../main.dart';
import 'api.dart';
import 'history.dart';
import 'model.dart';

class Chant extends StatelessWidget {
  const Chant({Key? key}) : super(key: key);

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

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>  with WidgetsBindingObserver{
  late AppLifecycleState _lastLifecycleState;
  late AudioPlayer _player;
  // String counterKey = 'home_counter';
  final box = Hive.box<dynamic>('mybox');


  // String counterKey2='home_counter2';
  int _malaCounter = 0;
  int _counter = 0;
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  void _incrementCounter() {
    // final box = Hive.box<int>('mybox');
    // int value = box.get(counterKey) ?? 0;
    // print("counter value $value");
    // _counter = value;

    setState(() {
      _counter++;
    });
    // box.put(counterKey, _counter);
  }

  void _clear() {
    setState(() {
      _counter = 0;
      _malaCounter = 0;
    });
  }

  @override
  void initState() {
    // final box = Hive.box<int>('mybox');
    // int value =box.get(counterKey) ?? 0;
    // print("counter value $value");
    // _counter= value;
    WidgetsBinding.instance.addObserver(this);
    super.initState();

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      String appName = packageInfo.appName;
      print("app name = " + appName);
      String packageName = packageInfo.packageName;
      print("package name =" + packageName);
      String version = packageInfo.version;
      print("version =" + version);
      String buildNumber = packageInfo.buildNumber;
      print("build number =" + buildNumber);
      _callApi(version, packageName);
    });
    // ambiguate(WidgetsBinding.instance)!.addObserver(this);
    _player = AudioPlayer();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));

    _init();
  }

  final _playlist = ConcatenatingAudioSource(children: [
    // Remove this audio source from the Windows and Linux version because it's not supported yet
    if (kIsWeb ||
        ![TargetPlatform.windows, TargetPlatform.linux]
            .contains(defaultTargetPlatform))
      AudioSource.uri(
        Uri.parse("asset:///assets/shivayamantra.mp3"),
        tag: AudioMetadata(
          album: " lord shiva",
          title: "  Lord shiva chants",
          artwork:
              "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg",
        ),
      ),

    AudioSource.uri(
      Uri.parse("asset:///assets/om-chanting1.mpeg"),
      tag: AudioMetadata(
        album: " om ",
        title: "  om mantra",
        artwork:
            "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg",
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///assets/gayatri-mantra.mp3"),
      tag: AudioMetadata(
        album: "gayatri mantra",
        title: "  gayatri mantra",
        artwork:
            "https://thumbs.dreamstime.com/b/environment-earth-day-hands-trees-growing-seedlings-bokeh-green-background-female-hand-holding-tree-nature-field-gra-130247647.jpg",
      ),
    ),
    // AudioSource.uri(
    //   Uri.parse("asset:///assets/mantraspiritual.mp3"),
    //   tag: AudioMetadata(
    //     album: "mantra spiritual",
    //     title: "  Chanting om",
    //     artwork:
    //         "https://thumbs.dreamstime.com/b/environment-earth-day-hands-trees-growing-seedlings-bokeh-green-background-female-hand-holding-tree-nature-field-gra-130247647.jpg",
    //   ),
    // ),

    AudioSource.uri(
      Uri.parse("asset:///assets/shriSwamiSamarthJap.mp3"),
      tag: AudioMetadata(
        album: " shri swami samartha jap",
        title: " shri swami samartha jap",
        artwork:
            "https://thumbs.dreamstime.com/b/environment-earth-day-hands-trees-growing-seedlings-bokeh-green-background-female-hand-holding-tree-nature-field-gra-130247647.jpg",
      ),
    ),
  ]);

  Future<void> _callApi(version, packageName) async {
    ForceUpdateModel? data = await api.getData(version);
    if (data!.code == 1) {
      var appVersionFromApi = data.result![0].appVersion;
      if (version != appVersionFromApi) {
        AlertDialog(
          actions: [
            IconButton(
              icon: Icon(Icons.add, color: Colors.white, size: 30),
              onPressed: () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => const AlertDialog(
                  title: const Text('AlertDialog'),
                  content: const Text('please update your version'),
                ),
              ),
            ),
          ],
        );
      }
    }
  }

  Future<void> _init() async {
    // final session = await AudioSession.instance;
    // await session.configure(const AudioSessionConfiguration.speech());
    // Listen to errors during playback.
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
    try {
      // Preloading audio is not currently supported on Linux.
      await _player.setAudioSource(_playlist,
          preload: kIsWeb || defaultTargetPlatform != TargetPlatform.linux);
    } catch (e) {
      // Catch load errors: 404, invalid url...
      print("Error loading audio source: $e");
    }
    // Show a snackbar whenever reaching the end of an item in the playlist.
    _player.positionDiscontinuityStream.listen((discontinuity) {
      if (discontinuity.reason == PositionDiscontinuityReason.autoAdvance) {
        _showItemFinished(discontinuity.previousEvent.currentIndex);
      }
    });
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _showItemFinished(_player.currentIndex);
      }
    });
  }

  void _showItemFinished(int? index) {
    if (index == null) return;
    final sequence = _player.sequence;
    if (sequence == null) return;
    final source = sequence[index];
    final metadata = source.tag as AudioMetadata;
    _scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text('Finished playing ${metadata.title}'),
      duration: const Duration(seconds: 1),
    ));
  }

  @override
  void dispose() {
    // ambiguate(WidgetsBinding.instance)!.removeObserver(this);
    _player.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("mounika application $state");
    print("mounika application ${AppLifecycleState.detached}");
    print("mounika application ${AppLifecycleState.inactive}");
    print("mounika application ${AppLifecycleState.resumed}");
    if (state == AppLifecycleState.paused) {
      print("mounika applications closed");
      // Release the player's resources when not in use. We use "stop" so that
      // if the app resumes later, it will still remember what position to
      // resume from.
      _player.stop();
    }
  }

  String selected = "No Track";

  List<String> songsList = [
    "Lord Siva",
    "Om Martra",
    "Gayatri Mantra",
    "Changing Om",
    "Shri Swami Samartha Jap",
  ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var assetName = "assets/svg/Ellipse.svg";
    var asset1 = "assets/image/mala.png";


    String date = DateFormat("dd-MM-yyyy").format(DateTime.now());
    final GlobalKey<ScaffoldState> drawerscaffoldkey =
        GlobalKey<ScaffoldState>();
    print(" mounikkksfgydyfdy7fgfg$_counter");
    return Scaffold(
      key: drawerscaffoldkey,
      drawer: Drawer(
        child: ValueListenableBuilder(
            valueListenable: Hive.box<dynamic>('mybox').listenable(),
            builder: (context, box, child) {
              // final value = box.get(counterKey);
              return ListView(
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
                        MaterialPageRoute(builder: (context) =>  SecondRoute()),
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
                          "It provides an authentic, simple and the most powerful meditation for the modern age.")],
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
              );
            }),
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xff3D345F), Color(0xffE79997)])),
          child: Column(
            children: [
              Row(
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
                    child: LayoutBuilder(builder: (context, constraints) {
                      var hour = DateTime.now().hour;
                      var min = DateTime.now().minute;
                      print(hour);
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
                ],
              ),
              _playerA(size),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      child: Image.asset(
                        asset1,
                        height: size.height / 16,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    // color: Colors.black,
                    child: Text(
                      "Total mala",
                      style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: size.width / 25,
                          color: Colors.white,
                          decoration: TextDecoration.none),
                    ),
                  ),
                  Container(
                    height: size.height / 35,
                    child: Row(
                      children: [
                        MaterialButton(
                          // padding: EdgeInsets.fromLTRB(left, 10, rig, bottom),
                          // height: 28,
                          minWidth: size.width / 15,
                          color: Colors.white10,
                          // color: Color(0xffB0818E),
                          shape: RoundedRectangleBorder(

                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                          child: Center(
                            child: Text(
                              '$_malaCounter',
                              style: TextStyle(
                                  fontSize: size.width / 25,
                                  color: Colors.white,
                                  fontFamily:
                                      "assets/fonts/Poppins/Poppins-Regular.ttf",
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                          onPressed: () {

                          },
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Container(
                    height: size.height / 10,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: MaterialButton(
                            height: size.height / 25,
                            minWidth: 120,
                            color: Colors.white10,
                            // color: Color(0xffB0818E),
                            shape: RoundedRectangleBorder(
                                // side: BorderSide(
                                //     strokeAlign: StrokeAlign.center,
                                //     width: 14
                                // ),
                                borderRadius: BorderRadius.circular(20)),
                            elevation: 0,
                            child: Text("RESET",
                                style: TextStyle(
                                    fontFamily:
                                        "assets/fonts/Poppins/Poppins-Regular.ttf",
                                    fontSize: size.width / 27,
                                    color: Colors.white)),
                            onPressed: () {

                              // box.clear();
                              _clear();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Stack(
                children: [
                  Container(
                    height: size.height / 3.3,
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      assetName,
                      // semanticsLabel: 'Counter Logo'
                    ),
                  ),
                  Positioned(
                    top: size.height / 33,
                    left: size.width / 3.63,
                    child: SizedBox(
                      height: size.height / 4.5,
                      width: size.width / 2.25,
                      child: GestureDetector(
                        onTap: () {
                          _incrementCounter();
                          if (_counter % 108 == 0 && _counter != 0) {
                            _malaCounter++;
                          }

                          Vibration.vibrate(duration: 100, amplitude: 128);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Center(
                                child: Text(
                                  '$_counter',
                                  style: TextStyle(
                                      fontSize: size.width / 5,
                                      color: Colors.white),
                                  // Theme.of(context).textTheme.headline1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // child: FloatingActionButton(
                      //   elevation: 0,
                      //   backgroundColor: Color(0xffC1838B),
                      //   onPressed: () {
                      //     _incrementCounter();
                      //     if (_counter % 108 == 0 && _counter != 0) {
                      //       _malaCounter++;
                      //     }
                      //
                      //     Vibration.vibrate(duration: 100, amplitude: 128);
                      //
                      //     // HapticFeedback.vibrate();
                      //   },
                      //   tooltip: 'Increment',
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     children: [
                      //       Text(
                      //         '$_counter',
                      //         style:
                      //             TextStyle(fontSize: 70, color: Colors.white),
                      //         // Theme.of(context).textTheme.headline1,
                      //       ),
                      //     ],
                      //   ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _playerA(Size size) {
    var asset = "assets/image/chanting.jpg";

    var shadow = BoxShadow(
        color: Colors.black45, offset: Offset(0.0, 4.0), blurRadius: 5);

    return Container(
      // padding: EdgeInsets.symmetric(horizontal: 20),
      margin: EdgeInsets.symmetric(horizontal: 20),
      height: size.height / 2.3,
      // width: 200,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(44),
          boxShadow: [shadow]),
      child: Column(
        children: [
          Container(
            height: size.height / 5.5,
            // width: 200,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(44),
                boxShadow: [shadow]),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(44),
                      bottomLeft: Radius.circular(44)),
                  child: Image.asset(
                    asset,
                    height: size.height / 5.5,
                    width: size.width / 3.2,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                    // flex: 2,
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          // width: 100,
                          // height: 40,
                          // color: Colors.black,
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            selected,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: size.width / 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontFamily: "Poppins"),
                          ),
                          Text(
                            " $selected",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: size.width / 35,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontFamily:
                                  "assets/fonts/Poppins/Poppins-Regular.ttf",
                            ),
                          ),
                        ],
                      )),
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            // height: 30,
                            // width: 150,
                            child: ProgressBar(
                              progressBarColor: Color(0xff3D345F),
                              baseBarColor: Colors.grey,
                              onDragStart: (details) {
                                _player.seek(Duration.zero,
                                    index: _player.currentIndex);
                              },
                              progress: Duration(),
                              // (milliseconds:000,),
                              barHeight: size.height / 165,
                              thumbColor: Color(0xff3D345F),
                              thumbRadius: 6,
                              // buffered: Duration(milliseconds: 2000),
                              total: Duration(milliseconds: 30000),

                              onSeek: (Duration) {
                                _player.seek(Duration,
                                    index: _player.currentIndex);
                                print('User selected a new time: $Duration');
                              },
                            ),
                          ),
                        ),
                      ),
                      ControlButtons(_player)
                    ],
                  ),
                )),
              ],
            ),
          ),
          SizedBox(height: size.height / 68),
          Text("Playlist",
              style: TextStyle(
                fontSize: size.width / 25,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins",
              )),
          SizedBox(height: size.height / 90),
          Container(
            height: size.height / 5.2,
            // color: Colors.amber,
            child: StreamBuilder<SequenceState?>(
              stream: _player.sequenceStateStream,
              builder: (context, snapshot) {
                final state = snapshot.data;
                final sequence = state?.sequence ?? [];
                return ReorderableListView(
                  onReorder: (int oldIndex, int newIndex) {
                    if (oldIndex < newIndex) newIndex--;
                    _playlist.move(oldIndex, newIndex);
                  },
                  children: List.generate(sequence.length, (index) {
                    return _trackListTile(
                      count: index + 1,
                      title: sequence[index].tag.title as String,
                      key: ValueKey(sequence[index]),
                    );
                  }),
                );
              },
            ),

            // ListView(
            //     shrinkWrap: true,
            //     children: List.generate(songsList.length, (index) {
            //       return _trackListTile(
            //           count: index + 1, title: songsList[index]);
            //     })),
          )
        ],
      ),
    );
  }

  Widget _trackListTile({count, title, key}) {
    return GestureDetector(
      key: key,
      onTap: () {
        setState(() {
          _player.seek(Duration.zero, index: count - 1);
          selected = title;
        });
      },
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              SizedBox(width: 33),
              Text(count.toString() + ".",
                  style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 12,
                      color:
                          selected == title ? Color(0xffB0818E) : Colors.grey,
                      fontWeight: selected == title
                          ? FontWeight.bold
                          : FontWeight.w300)),
              SizedBox(width: 12),
              Text(title,
                  style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 12,
                      color:
                          selected == title ? Color(0xffB0818E) : Colors.grey,
                      fontWeight: selected == title
                          ? FontWeight.bold
                          : FontWeight.w300)),
            ],
          ),
        ),
      ),
    );
  }
}

class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  const ControlButtons(this.player, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var assetName1 = "assets/svg/chevronleft.svg";
    var assetName2 = "assets/svg/chevronright.svg";
    var assetName3 = "assets/svg/pause.svg";
    var assetName4 = "assets/svg/play.svg";
    var assetName5 = "assets/svg/volume.svg";

    return Row(
      // crossAxisAlignment: CrossAxisAlignment.start,
      // mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Container(
            // color: Colors.amber,
            // height:size.height/23,
            // width: size.width/10,
            child: StreamBuilder<double>(
              stream: player.speedStream,
              builder: (context, snapshot) => IconButton(
                color: Color(0xff3D345F),
                icon: SvgPicture.asset(
                  assetName5,
                  // icon: const Icon(Icons.play_arrow_rounded),
                ),
                // icon: const Icon(Icons.volume_down_outlined),
                onPressed: () {
                  showSliderDialog(
                    context: context,
                    title: "Adjust volume",
                    divisions: 10,
                    min: 0.0,
                    max: 1.0,
                    value: player.volume,
                    stream: player.volumeStream,
                    onChanged: player.setVolume,
                  );
                },
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            // color: Colors.green,
            // height:size.height/23,
            // width: size.width/10,
            // height: 30,
            // width: 30,
            child: StreamBuilder<SequenceState?>(
              stream: player.sequenceStateStream,
              builder: (context, snapshot) => IconButton(
                color: const Color(0xff3D345F),
                icon: SvgPicture.asset(
                  assetName1,
                  // fit: BoxFit.cover,
                  // icon: const Icon(Icons.play_arrow_rounded),
                ),
                onPressed: player.hasPrevious ? player.seekToPrevious : null,
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<PlayerState>(
            stream: player.playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data;
              final processingState = playerState?.processingState;
              final playing = playerState?.playing;
              if (processingState == ProcessingState.loading ||
                  processingState == ProcessingState.buffering) {
                return Container(
                  width: 20.0,
                  height: 25.0,
                  child: const CircularProgressIndicator(),
                );
              } else if (playing != true) {
                return SizedBox(
                  // height: 30,
                  // width: 30,
                  child: IconButton(
                    color: const Color(0xff3D345F),
                    icon: SvgPicture.asset(
                      assetName4,
                      // icon: const Icon(Icons.play_arrow_rounded),
                    ),
                    // iconSize: 25.0,
                    onPressed: player.play,
                  ),
                );
              } else if (processingState != ProcessingState.completed) {
                return SizedBox(
                  // height: 30,
                  // width: 30,
                  child: IconButton(
                    icon: SvgPicture.asset(
                      assetName3,
                      // icon: const Icon(Icons.play_arrow_rounded),
                    ),
                    iconSize: 25.0,
                    onPressed: player.pause,
                  ),
                );
              } else {
                return SizedBox(
                  // height: 30,
                  // width: 25,
                  child: IconButton(
                    icon: const Icon(Icons.replay),
                    iconSize: 25.0,
                    onPressed: () => player.seek(Duration.zero,
                        index: player.effectiveIndices!.first),
                  ),
                );
              }
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<SequenceState?>(
            stream: player.sequenceStateStream,
            builder: (context, snapshot) => SizedBox(
              // height: 30,
              // width: 30,
              child: IconButton(
                  color: const Color(0xff3D345F),
                  icon: SvgPicture.asset(
                    assetName2,
                    // icon: const Icon(Icons.play_arrow_rounded),
                  ),
                  onPressed: () {
                    player.hasNext ? player.seekToNext : null;
                  }),
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            // height:size.height/ 30,
            // width: size.width/10,
            child: StreamBuilder<double>(
              stream: player.speedStream,
              builder: (context, snapshot) => IconButton(
                icon: Center(
                  child: Text("${snapshot.data?.toStringAsFixed(1)}x",
                      style: TextStyle(
                          fontSize: size.width / 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff3D345F))),
                ),
                onPressed: () {
                  showSliderDialog(
                    context: context,
                    title: "Adjust speed",
                    divisions: 10,
                    min: 0.5,
                    max: 1.5,
                    value: player.speed,
                    stream: player.speedStream,
                    onChanged: player.setSpeed,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  void showSliderDialog({
    required BuildContext context,
    required String title,
    required int divisions,
    required double min,
    required double max,
    String valueSuffix = '',
    // TODO: Replace these two by ValueStream.
    required double value,
    required Stream<double> stream,
    required ValueChanged<double> onChanged,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, textAlign: TextAlign.center),
        content: StreamBuilder<double>(
          stream: stream,
          builder: (context, snapshot) => SizedBox(
            height: 100.0,
            child: Column(
              children: [
                Text('${snapshot.data?.toStringAsFixed(1)}$valueSuffix',
                    style: const TextStyle(
                        fontFamily: 'Fixed',
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0)),
                Slider(
                  divisions: divisions,
                  min: min,
                  max: max,
                  value: snapshot.data ?? value,
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AudioMetadata {
  final String album;
  final String title;
  final String artwork;

  AudioMetadata({
    required this.album,
    required this.title,
    required this.artwork,
  });
}
