import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:marquee/marquee.dart';
import 'package:vibration/vibration.dart';

import '../main.dart';

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

class _MyHomePageState extends State<MyHomePage> {
  late AudioPlayer _player;
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
      Uri.parse("asset:///assets/om.mp3"),
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
      Uri.parse("asset:///assets/mantraspiritual.mp3"),
      tag: AudioMetadata(
        album: "mantra spiritual",
        title: "  Chanting om",
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
  int _malaCounter = 0;
  int _counter = 0;
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      // _counter++;

      _counter++;
    });
  }

  void _clear() {
    setState(() {
      _counter = 0;
      _malaCounter = 0;
    });
  }

  @override
  void initState() {
    super.initState();
    // ambiguate(WidgetsBinding.instance)!.addObserver(this);

    _player = AudioPlayer();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    _init();
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
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
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

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xff3D345F), Color(0xffE79997)])),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Container(
                alignment: Alignment.topLeft,
                padding: (EdgeInsets.all(30)),
                // color: Colors.blue,
                child: const Text(
                  "Good afternoon",
                  style: TextStyle(
                      fontFamily: "Noto_Sans",
                      fontSize: 24,
                      color: Colors.white,
                      // fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none),
                  textAlign: TextAlign.start,
                ),
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
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    // color: Colors.black,
                    child: const Text(
                      "Total mala",
                      style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 16,
                          color: Colors.white,
                          decoration: TextDecoration.none),
                    ),
                  ),
                  Container(
                    height: 20,
                    child: Row(
                      children: [
                        MaterialButton(
                          // padding: EdgeInsets.fromLTRB(left, 10, rig, bottom),
                          height: 28,
                          minWidth: 30,
                          color: Colors.white10,
                          // color: Color(0xffB0818E),
                          shape: RoundedRectangleBorder(
                              // side: BorderSide(
                              //     strokeAlign: StrokeAlign.center,
                              //     width: 14
                              // ),
                              borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                          child: Text(
                            '$_malaCounter',
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontFamily:
                                    "assets/fonts/Poppins/Poppins-Regular.ttf",
                                fontWeight: FontWeight.w900),
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Container(
                    height: 70,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: MaterialButton(
                            height: 35,
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
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("RESET",
                                  style: TextStyle(
                                      fontFamily:
                                          "assets/fonts/Poppins/Poppins-Regular.ttf",
                                      fontSize: 14,
                                      color: Colors.white)),
                            ),
                            onPressed: () {
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
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      assetName,
                      // semanticsLabel: 'Counter Logo'
                    ),
                  ),
                  Positioned(
                    top: 25,
                    left: 107,
                    child: SizedBox(
                      height: 180,
                      width: 180,
                      child: GestureDetector(
                        onTap: (){
                          _incrementCounter();
                          if (_counter % 108 == 0 && _counter != 0) {
                            _malaCounter++;
                          }

                          Vibration.vibrate(duration: 100, amplitude: 128);
                        },

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$_counter',
                              style:
                              TextStyle(fontSize: 70, color: Colors.white),
                              // Theme.of(context).textTheme.headline1,
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
      height: 350,
      // width: 200,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [shadow]),
      child: Column(
        children: [
          Container(
            height: 150,
            // width: 200,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [shadow]),
            child: Row(
              children: [
                Expanded(
                    child: Container(
                  // color: Colors.grey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(35),
                          child: Image.asset(
                            asset,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // decoration: BoxDecoration(
                  //   image: DecorationImage(
                  //     image: AssetImage("assets/image/chanting.jpg"),
                  //     fit: BoxFit.fill,
                  //   )
                  // ),
                )),
                Expanded(
                    // flex: 2,
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
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: "Poppins"),
                        ),
                        Text(
                          selected,
                          style: const TextStyle(
                            fontSize: 14,
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
                          height: 30,
                          width: 150,
                          child:
                          StreamBuilder<PositionData>(
                            stream: _positionDataStream,
                            builder: (context, snapshot) {
                              final positionData = snapshot.data;
                              return SeekBar(
                                duration: positionData?.duration ?? Duration.zero,
                                position: positionData?.position ?? Duration.zero,
                                bufferedPosition:
                                positionData?.bufferedPosition ?? Duration.zero,
                                onChangeEnd: _player.seek,
                              );
                            },
                          ),


                          // ProgressBar(
                          //
                          //   progressBarColor: Colors.grey,
                          //   baseBarColor: Colors.grey,
                          //   progress: Duration(milliseconds: 1000),
                          //   thumbColor: Color(0xff3D345F),
                          //   thumbRadius: 6,
                          //   buffered: Duration(milliseconds: 2000),
                          //   total: Duration(milliseconds: 5000),
                          //
                          //   onSeek: (duration) {
                          //     print('User selected a new time: $duration');
                          //   },
                          // ),
                        ),
                      ),
                    ),
                    ControlButtons(_player)
                  ],
                )),
              ],
            ),
          ),
          const SizedBox(height: 12.0),
          const Text("Playlist",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins",
              )),
          const SizedBox(height: 12.0),
          Container(
            height: size.height / 5.3,
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

                  children:
                  List.generate(sequence.length, (index) {
                    return _trackListTile(
                        count: index + 1,
                        title: sequence[index].tag.title as String,
                        key: ValueKey(sequence[index]));

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

  Widget _trackListTile({required count, required title, required key}) {
    return GestureDetector(
      key: key,
      onTap: () {
        setState(() {
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
    var assetName1 = "assets/svg/chevronleft.svg";
    var assetName2 = "assets/svg/chevronright.svg";
    var assetName3 = "assets/svg/pause.svg";
    var assetName4 ="assets/svg/play.svg";
    var assetName5 ="assets/svg/volume.svg";
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [

        SizedBox(
          height: 40,
          width: 40,
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
        SizedBox(
          height: 40,
          width: 40,
          child: StreamBuilder<SequenceState?>(
            stream: player.sequenceStateStream,
            builder: (context, snapshot) => IconButton(
              color: const Color(0xff3D345F),
                icon: SvgPicture.asset(
                  assetName1,
                  // icon: const Icon(Icons.play_arrow_rounded),
                ),

              onPressed:(){
                player.hasPrevious ? player.seekToPrevious : null;
                Vibration.vibrate(duration: 100, amplitude: 128);
              }
            ),
          ),
        ),

        StreamBuilder<PlayerState>(
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
            }
            else if (playing != true) {
              return SizedBox(
                height: 40,
                width: 40,
                child:
                IconButton(
                  color: const Color(0xff3D345F),
                  icon: SvgPicture.asset(
                    assetName4,
                  // icon: const Icon(Icons.play_arrow_rounded),
                ),
                  // iconSize: 25.0,
                  onPressed: player.play,
                ),
              );
            }
            else if (processingState != ProcessingState.completed) {
              return SizedBox(
                height: 40,
                width: 40,
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
                height: 40,
                width: 25,
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
        
        StreamBuilder<SequenceState?>(
          stream: player.sequenceStateStream,
          builder: (context, snapshot) => SizedBox(
            height: 40,
            width: 40,
            child: IconButton(
              color: const Color(0xff3D345F),
                icon: SvgPicture.asset(
                  assetName2,
                  // icon: const Icon(Icons.play_arrow_rounded),
                ),
              onPressed: (){
                player.hasNext ? player.seekToNext : null;
              }
            ),
          ),
        ),
        SizedBox(
          height: 40,
          width: 70,
          child: StreamBuilder<double>(
            stream: player.speedStream,
            builder: (context, snapshot) => IconButton(
              icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xff3D345F))),
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
