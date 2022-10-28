// This example demonstrates how to play a playlist with a mix of URI and asset
// audio sources, and the ability to add/remove/reorder playlist items.
//
// To run:
//
// flutter run -t lib/example_playlist.dart

// import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vibration/vibration.dart';
import 'package:yt_counter/audio_demo.dart';
import 'package:yt_counter/chanting/api.dart';
import 'package:yt_counter/chanting/ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() => runApp(const Chant());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late AudioPlayer _player;

  final _playlist = ConcatenatingAudioSource(children: [
    // Remove this audio source from the Windows and Linux version because it's not supported yet
    if (kIsWeb ||
        ![TargetPlatform.windows, TargetPlatform.linux]
            .contains(defaultTargetPlatform))
      // ClippingAudioSource(
      //   start: const Duration(seconds: 60),
      //   end: const Duration(seconds: 90),
      //   child: AudioSource.uri(Uri.parse(
      //       "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3")),
      //   tag: AudioMetadata(
      //     album: "Science Friday",
      //     title: "A Salute To Head-Scratching Science (30 seconds)",
      //     artwork:
      //     "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg",
      //   ),
      // ),


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
      _malaCounter=0;
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



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      home: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MaterialButton(
                color: Colors.black,
                child: const Text("RESET",
                    style: TextStyle(fontSize: 20, color: Colors.white)),
                onPressed: () {
                  _clear();
                },
              ),

              const Spacer(),

              SizedBox(
                height: 300,
                width: 300,
                child: FloatingActionButton(
                  backgroundColor: Colors.grey,
                  onPressed: () {
                    _incrementCounter();
                    if(_counter%108== 0&& _counter !=0){

                      _malaCounter++;
                    }

                    Vibration.vibrate(duration: 100, amplitude: 128);

                  },
                  // onPressed: _incrementCounter,
                  tooltip: 'Increment',
                  child: Column(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$_counter',
                        style: TextStyle(fontSize: 100, color: Colors.white),
                        // Theme.of(context).textTheme.headline1,
                      ),
                      Text(
                        '$_malaCounter mala completed',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                        // Theme.of(context).textTheme.headline1,
                      ),
                    ],
                  ),
                  //const Icon(
                  //   Icons.add,
                  //   size: 150,
                  // ),
                ),
              ),
              const Spacer(),

              ControlButtons(_player),

              const SizedBox(height: 8.0),
              Row(
                children: [

                  Spacer(),
                  Expanded(
                    child: Text(
                      "Playlist",
                      style: Theme.of(context).textTheme.headline6,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Spacer(),

                ],
              ),
              SizedBox(
                height: 240.0,
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
                      children: [
                        for (var i = 0; i < sequence.length; i++)
                          Dismissible(
                            key: ValueKey(sequence[i]),
                            background:

                            Container(
                              color: Colors.redAccent,
                              alignment: Alignment.centerRight,
                              child: const Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Icon(Icons.delete, color: Colors.white),
                              ),
                            ),
                            onDismissed: (dismissDirection) {
                              _playlist.removeAt(i);
                            },
                            child: Material(
                              color: i == state!.currentIndex
                                  ? Colors.amber
                                  : null,
                              child: ListTile(
                                title: Text(sequence[i].tag.title as String),
                                onTap: () {
                                  _player.seek(Duration.zero, index: i);
                                },
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // floatingActionButton: FloatingActionButton(
        //   child: const Icon(Icons.add),
        //   onPressed: () {
        //     _playlist.add(AudioSource.uri(
        //       Uri.parse("asset:///audio/nature.mp3"),
        //       tag: AudioMetadata(
        //         album: "Public Domain",
        //         title: "Nature Sounds ${++_addedCount}",
        //         artwork:
        //         "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg",
        //       ),
        //     ));
        //   },
        // ),
      ),
    );
  }
}

class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  const ControlButtons(this.player, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
       children: [
        StreamBuilder<double>(
          stream: player.speedStream,
          builder: (context, snapshot) => IconButton(
            icon:const Icon(Icons.volume_up),
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
        // SizedBox(
        //   height: 10,
        //   width: 10,
        //   child: IconButton(
        //     icon: const Icon(Icons.volume_up),
        //     onPressed: () {
        //       showSliderDialog(
        //         context: context,
        //         title: "Adjust volume",
        //         divisions: 10,
        //         min: 0.0,
        //         max: 1.0,
        //         value: player.volume,
        //         stream: player.volumeStream,
        //         onChanged: player.setVolume,
        //       );
        //     },
        //   ),
        // ),
        StreamBuilder<SequenceState?>(
          stream: player.sequenceStateStream,
          builder: (context, snapshot) => IconButton(
            icon: const Icon(Icons.skip_previous),
            onPressed:

            player.hasPrevious ? player.seekToPrevious : null,
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
                margin: const EdgeInsets.all(8.0),
                width: 64.0,
                height: 64.0,
                child: const CircularProgressIndicator(),
              );
            } else if (playing != true) {
              return IconButton(
                icon: const Icon(Icons.play_arrow),
                iconSize: 64.0,
                onPressed: player.play,
              );
            } else if (processingState != ProcessingState.completed) {
              return IconButton(
                icon: const Icon(Icons.pause),
                iconSize: 64.0,
                onPressed: player.pause,
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.replay),
                iconSize: 64.0,
                onPressed: () => player.seek(Duration.zero,
                    index: player.effectiveIndices!.first),
              );
            }
          },
        ),
        StreamBuilder<SequenceState?>(
          stream: player.sequenceStateStream,
          builder: (context, snapshot) => IconButton(
            icon: const Icon(Icons.skip_next),
            onPressed: player.hasNext ? player.seekToNext : null,
          ),
        ),
        Spacer(),
        StreamBuilder<double>(
          stream: player.speedStream,
          builder: (context, snapshot) => IconButton(
            icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
                style: const TextStyle(fontWeight: FontWeight.bold)),
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
        Spacer()
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

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:vibration/vibration.dart';
// import 'package:just_audio/just_audio.dart';
//
// AudioPlayer? player;
//
// void main() {
//   player = AudioPlayer();
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       // initialRoute: AppRoutes.home,
//       // routes: {
//       //   AppRoutes.home: (context) => const MyHomePage(title: '',),
//       // },
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // Try running your application with "flutter run". You'll see the
//         // application has a blue toolbar. Then, without quitting the app, try
//         // changing the primarySwatch below to Colors.green and then invoke
//         // "hot reload" (press "r" in the console where you ran "flutter run",
//         // or simply save your changes to "hot reload" in a Flutter IDE).
//         // Notice that the counter didn't reset back to zero; the application
//         // is not restarted.
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }
//
// // class Home extends StatelessWidget {
// //   const Home({Key? key}) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return SizedBox(
// //       child: Scaffold(
// //         appBar: AppBar(title: const Text("title")),
// //         body: const Center(
// //           child: AudioPlayers(),
// //         ),
// //       ),
// //     );
// //   }
// // }
//
// // class AppRoutes {
// //   static String home = "/";
// // }
// //
// // // ignore: unused_element
// // Duration _position = const Duration(seconds: 0);
// // var _progress = 0.0;
//
// // class AudioPlayers extends StatefulWidget {
// //   const AudioPlayers({Key? key}) : super(key: key);
// //
// //   @override
// //   State<AudioPlayers> createState() => _AudioPlayersState();
// // }
// // class _AudioPlayersState extends State<AudioPlayers> {
// //   Timer? timer2;
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       padding: const EdgeInsets.all(8),
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           LinearProgressIndicator(
// //             value: _progress,
// //           ),
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               IconButton(
// //                   onPressed: () {
// //                     player!.setAsset('assets/mb3.mp3').then((value) {
// //                       return {
// //                         _position = value!,
// //                         player!.playerStateStream.listen((state) {
// //                           if (state.playing) {
// //                             setState(() {
// //                               _progress = .1;
// //                             });
// //                           } else {
// //                             switch (state.processingState) {
// //                               case ProcessingState.idle:
// //                                 break;
// //                               case ProcessingState.loading:
// //                                 break;
// //                               case ProcessingState.buffering:
// //                                 break;
// //                               case ProcessingState.ready:
// //                                 setState(() {
// //                                   _progress = 0;
// //                                   timer2!.cancel();
// //                                 });
// //                                 break;
// //                               case ProcessingState.completed:
// //                                 setState(() {
// //                                   _progress = 1;
// //                                 });
// //                                 break;
// //                             }
// //                           }
// //                         }),
// //                         player!.play(),
// //                         timer2 =
// //                             Timer.periodic(const Duration(seconds: 1), (timer) {
// //                               setState(() {
// //                                 _progress += .05;
// //                               });
// //                             })
// //                       };
// //                     });
// //                   },
// //                   icon: Icon(
// //                     _progress > 0 ? Icons.pause : Icons.play_circle_fill,
// //                     size: 45,
// //                   )),
// //               const SizedBox(
// //                 width: 45,
// //               ),
// //               IconButton(
// //                   onPressed: () {
// //                     player!.stop();
// //                     timer2!.cancel();
// //                   },
// //                   icon: const Icon(
// //                     Icons.stop,
// //                     size: 45,
// //                   )),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//
//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.
//   //
//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;
//
//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       // _counter++;
//       if (_counter < 20) {
//         _counter++;
//       }
//     });
//   }
//
//   void _clear() {
//     setState(() {
//       _counter = 0;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: const Text("YT_Counter"),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           // mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             // const Text(
//             //   'You have pushed the button this many times:',
//             // ),
//             Text(
//               '$_counter' "/20",
//               style: Theme.of(context).textTheme.headline4,
//             ),
//             const Spacer(),
//             SizedBox(
//               height: 200,
//               width: 200,
//               child: FloatingActionButton(
//                 onPressed: () {
//                   _incrementCounter();
//                   Vibration.vibrate(duration: 100, amplitude: 128);
//                   // HapticFeedback.vibrate();
//                 },
//                 // onPressed: _incrementCounter,
//                 tooltip: 'Increment',
//                 child: const Icon(
//                   Icons.add,
//                   size: 150,
//                 ),
//               ),
//             ),
//             const Spacer(),
//             MaterialButton(
//               color: Colors.blue,
//               child: const Text("RESET",
//                   style: TextStyle(fontSize: 30, color: Colors.white)),
//               onPressed: () {
//                 // HapticFeedback.heavyImpact();
//                 _clear();
//                 // Vibration.vibrate(duration: 1000, amplitude: 128);
//                 // Vibration.vibrate(
//                 //   pattern: [ 4000, 5000],
//                 // );
//               },
//               // onPressed: _clear,
//             )
//           ],
//         ),
//       ),
//
//       // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
