import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:interactive_slider/interactive_slider.dart';
import 'package:music_demo/widgets/audio_form_widget.dart';
import 'package:music_demo/widgets/wide_button.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:just_waveform/just_waveform.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:volume_controller/volume_controller.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({Key? key}) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final progressStream = BehaviorSubject<WaveformProgress>();
  final audioPlayer = AudioPlayer();
  late Duration audioDuration;
  Duration audioPosition = Duration.zero;
  late StreamSubscription<Duration> audioPositionSubscription;

  double _volumeListenerValue = 0;
  double _getVolume = 0;
  double _setVolumeValue = 2;

  @override
  void initState() {
    super.initState();
    _init();

    VolumeController().listener((volume) {
      setState(() => _volumeListenerValue = volume);
    });

    VolumeController().getVolume().then((volume) => _setVolumeValue = volume);
  }

  Future<void> _init() async {
    final audioFile =
    File(p.join((await getTemporaryDirectory()).path, 'audio.mp3'));
    try {
      await audioFile.writeAsBytes(
          (await rootBundle.load('assets/audio.mp3')).buffer.asUint8List());
      final waveFile =
      File(p.join((await getTemporaryDirectory()).path, 'audio.wave'));
      JustWaveform.extract(audioInFile: audioFile, waveOutFile: waveFile)
          .listen(progressStream.add, onError: progressStream.addError);

      // Load and play audio
      await audioPlayer.setFilePath(audioFile.path);
      audioDuration = await audioPlayer.load() ?? Duration.zero;
      audioPositionSubscription = audioPlayer.positionStream.listen((position) {
        setState(() {
          audioPosition = position;
        });
      });
    } catch (e) {
      progressStream.addError(e);
    }
  }

  @override
  void dispose() {
    audioPositionSubscription.cancel();
    audioPlayer.dispose();
    VolumeController().removeListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xff261F26),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Music',
                      style: TextStyle(fontSize: 25, color: Colors.white),
                    ),
                    Text(
                      '237 online',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
              OutlineBorderButton(
                  backgroundColor: const Color(0xff874887),
                  title: "Back To Plinko",
                  textStyle: const TextStyle(fontSize: 25, color: Colors.white),
                  radius: 10,
                  borderColor: const Color(0xff874887),
                  height: MediaQuery.of(context).size.height*0.08,
                ),
                const SizedBox(
                  height: 25,
                ),
                const Text("Jubilant Day (Upbeat Lo-fi Hip Hop Mix))", style: TextStyle(color: Colors.white, fontSize: 23, overflow: TextOverflow.ellipsis),),
                const Text("Normandy Beach Party", style: TextStyle(color: Color(0xff786379), fontSize: 15, overflow: TextOverflow.ellipsis),),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  height: 250.0,
                  decoration: const BoxDecoration(
                    //color: Colors.grey.shade200,
                    color: Color(0xff393038),
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  width: double.maxFinite,
                  child: StreamBuilder<WaveformProgress>(
                    stream: progressStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      final progress = snapshot.data?.progress ?? 0.0;
                      final waveform = snapshot.data?.waveform;
                      if (waveform == null) {
                        return Center(
                          child: Text(
                            '${(100 * progress).toInt()}%',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        );
                      }
                      return AudioWaveformWidget(
                        waveform: waveform,
                        currentPosition: audioPosition,
                        numBars: 20, // Number of bars to display
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Container(
                          height: MediaQuery.of(context).size.width*0.20,
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: Color(0xff372E37),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: const Center(child: FaIcon(FontAwesomeIcons.backward, color: Colors.white, size: 35,)),
                        ),
                      ),
                      const SizedBox(width: 15,),
                      Expanded(
                        child: GestureDetector(
                          onTap: (){
                            if(audioPlayer.playerState.playing){
                              audioPlayer.pause();
                            }
                            else{
                              audioPlayer.play();
                            }
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.width*0.20,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xffFF8DD4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(child: FaIcon(audioPlayer.playerState.playing? FontAwesomeIcons.pause: FontAwesomeIcons.play, color: Colors.white, size: 35,)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15,),
                      Expanded(
                        child: Container(
                          height: MediaQuery.of(context).size.width*0.20,
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: Color(0xff372E37),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(30),
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(30),
                            ),
                          ),
                          child: const Center(child: FaIcon(FontAwesomeIcons.forward, color: Colors.white, size: 35,)),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                InteractiveSlider(
                  unfocusedOpacity: 0.8,
                  unfocusedHeight: 20,
                  backgroundColor: const Color(0xff372E37),
                  foregroundColor: const Color(0xffCA8AB2),
                  startIcon: const Icon(CupertinoIcons.volume_down),
                  endIcon: const Icon(CupertinoIcons.volume_up),
                  min: 1.0,
                  max: 15.0,
                  onChanged: (double value) {
                    _setVolumeValue = value;
                    VolumeController().setVolume(_setVolumeValue);
                    setState(() {});
                  },
                  initialProgress: _setVolumeValue,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}