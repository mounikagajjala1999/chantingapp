import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:just_audio/just_audio.dart';

class ControlButtonsWidget extends StatelessWidget {
  const ControlButtonsWidget({Key? key, required this.player}) : super(key: key);
  final AudioPlayer player;

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
            height:size.height/15,
            child: StreamBuilder<double>(
              stream: player.speedStream,
              builder: (context, snapshot) => IconButton(
                color: Color(0xff3D345F),
                icon: SvgPicture.asset(
                  assetName5,
                ),
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
            height:size.height/15,
            child: StreamBuilder<SequenceState?>(
              stream: player.sequenceStateStream,
              builder: (context, snapshot) => IconButton(
                color: const Color(0xff3D345F),
                icon: SvgPicture.asset(
                  assetName1,
                ),
                onPressed: player.hasPrevious
                    ? player.seekToPrevious
                    : null,
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
                return Container(
                  // color: Colors.grey,
                  height:size.height/15,
                  child: SizedBox(
                    child: IconButton(
                      color: const Color(0xff3D345F),
                      icon: SvgPicture.asset(
                        assetName4,
                      ),
                      // iconSize: 25.0,
                      onPressed: player.play,
                    ),
                  ),
                );
              } else if (processingState != ProcessingState.completed) {
                return Container(
                  height:size.height/15,
                  child: SizedBox(
                    child: IconButton(
                      icon: SvgPicture.asset(
                        assetName3,
                      ),
                      iconSize: 25.0,
                      onPressed: player.pause,
                    ),
                  ),
                );
              } else {
                return SizedBox(
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
              child: Container(
                // color: Colors.amber,
                height:size.height/15,
                child: IconButton(
                    color: const Color(0xff3D345F),
                    icon: SvgPicture.asset(
                      assetName2,
                    ),
                    onPressed: () {

                      player.hasNext
                          ? player.seekToNext()
                          : null;
                    }),

              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            // color: Colors.grey,
            height:size.height/19,
            child: SizedBox(
              // height:size.height/ 30,
              // width: size.width/10,
              child: StreamBuilder<double>(
                stream: player.speedStream,
                builder: (context, snapshot) => IconButton(
                  icon: Center(
                    child: Text("${snapshot.data?.toStringAsFixed(1)}x",
                        style: TextStyle(
                            fontSize: size.width / 35,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff3D345F))),
                  ),
                  iconSize: size.height/20,
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
