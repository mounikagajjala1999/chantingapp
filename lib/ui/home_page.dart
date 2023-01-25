import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vibration/vibration.dart';
import 'package:yt_counter/chanting/api.dart';
import 'package:yt_counter/chanting/model.dart';
import 'package:yt_counter/chanting/post_api.dart';
import 'package:yt_counter/main.dart';
import 'package:yt_counter/my_app.dart';
import 'package:yt_counter/res/audio_metadata.dart';
import 'package:yt_counter/ui/histroy_page.dart';
import 'package:yt_counter/widgets/control_buttons_widget.dart';
import 'package:yt_counter/widgets/drawer.dart';
import 'package:yt_counter/widgets/my_appbar_widget.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class DurationState {
  const DurationState(
      {required this.progress, required this.buffered, required this.total});

  final Duration progress;
  final Duration buffered;
  final Duration total;
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  late AppLifecycleState _lastLifecycleState;
  late AudioPlayer _player;
  String counterKey = 'home_counter';
  final box = Hive.box<dynamic>('mybox');
  int _malaCounter = 0;
  int _counter = 0;
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _clear() {
    String time = DateFormat("hh:mm:ss a").format(DateTime.now());
    String date = DateFormat("dd-MM-yyyy").format(DateTime.now());
    if (_counter != 0) {
      final box = Hive.box<dynamic>('mybox');
      List<String> list = box.get(counterKey) ?? [];
      list.add("$_counter $date $time");
      box.put(counterKey, list);
    }
    setState(() {
      _counter = 0;
      _malaCounter = 0;
    });
  }

  @override
  void initState() {
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
    ForceUpdateModel? data = await apiget.getData(version);
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
    // print("mounika application $state");
    // print("mounika application ${AppLifecycleState.detached}");
    // print("mounika application ${AppLifecycleState.inactive}");
    // print("mounika application ${AppLifecycleState.resumed}");
    if (state == AppLifecycleState.inactive) {
      // final box = Hive.box<dynamic>('mybox');
      // list.add("$_counter $date $time");
      //
      // box.put(counterKey, list);
      // print("mounika applications closed");
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

    final GlobalKey<ScaffoldState> drawerscaffoldkey =
        GlobalKey<ScaffoldState>();

    return Scaffold(
      key: drawerscaffoldkey,
      drawer: const MyDrawer(),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xff3D345F), Color(0xffE79997)])),
          child: SizedBox(
            // height: size.height,
            child: Column(
              children: [
                MyAppBarWidget(drawerscaffoldkey: drawerscaffoldkey),
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
                            onPressed: () {},
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
                GestureDetector(
                  onTap: () {
                    _incrementCounter();
                    if (_counter % 108 == 0 && _counter != 0) {
                      _malaCounter++;
                    }

                    Vibration.vibrate(duration: 100, amplitude: 128);
                  },
                  child: Stack(
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Text(
                                  '$_counter',
                                  style: TextStyle(
                                      fontSize: size.width / 5,
                                      color: Colors.white),
                                  // Theme.of(context).textTheme.headline1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
      // height: size.height / 2.3,
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
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(44),
                      bottomLeft: Radius.circular(44)),
                  child: Image.asset(
                    asset,
                    height: size.height / 5.3,
                    width: size.width / 3.5,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  // flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            // width: size.width/4,
                            // height: size.height/18,
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
                          // color: Colors.cyan,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: size.height / 35,
                              width: size.width / 2,
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
                        ControlButtonsWidget(player: _player)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: size.height / 68),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 140),
                child: Text("Playlist",
                    style: TextStyle(
                      fontSize: size.width / 25,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins",
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 95),
                child: MaterialButton(
                  minWidth: 50,

                  onPressed: () {},
                  child: const Icon(
                    Icons.file_upload_outlined,
                  ),
                ),
              )
            ],
          ),
          Container(
            height: size.height / 5.2,
            // color: Colors.amber,
            child: StreamBuilder<SequenceState?>(
              stream: _player.sequenceStateStream,
              builder: (context, snapshot) {
                final state = snapshot.data;
                final sequence = state?.sequence ?? [];
                return ReorderableListView(
                  physics: BouncingScrollPhysics(),
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
          ),
          SizedBox(height: size.height / 90),
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
