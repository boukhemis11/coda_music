import 'dart:async';

import 'package:flutter/material.dart';
import 'musique.dart';
import 'package:audioplayer/audioplayer.dart';

void main() => runApp(MyApp());
class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coda Music',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Coda Music'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<Musique> maListDeMusique = [
    Musique('Rai2018', 'Faycel', 'images/photo.jpg', 'https://www.jdid2018.com/music/Music-Dj-Remix/Rai-2019-Jdid/01.Faycel%20Sghir%20-%20Aachkek%20Historique.mp3'),
    Musique('Rai2018', 'Houssem', 'images/photo2.jpg', 'https://www.jdid2018.com/music/Music-Dj-Remix/Rai-2019-Jdid/02.Cheb%20Houssem%20-%203achkek%20Historique.mp3')
  ];

  Musique maMusiqueActuelle;
  Duration position = Duration(seconds: 0);
  Duration duree = Duration(seconds: 0);
  AudioPlayer audioPlayer ;
  StreamSubscription positionSub;
  StreamSubscription StateSubscription;
  PlayerState status = PlayerState.stopped;
  int index = 0;

  @override
  void initState() {
    super.initState();
    maMusiqueActuelle = maListDeMusique[index];
    configurationAudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    var largeur = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Card(
              elevation: 5,
              child: Container(
                height: largeur /1.5,
                width: largeur /1.5,
                child: Image.asset(maMusiqueActuelle.imagePath, fit: BoxFit.cover,),
              ),
            ),
            textStyle(maMusiqueActuelle.titre, 2),
            textStyle(maMusiqueActuelle.artiste,1),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                button(Icons.fast_rewind, 30, ActionMusic.rewind),
                button((status == PlayerState.playing) ?  Icons.pause: Icons.play_arrow , 45,(status == PlayerState.playing) ? ActionMusic.pause : ActionMusic.play),
                button(Icons.fast_forward, 30, ActionMusic.forward),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                textStyle(fromDuration(position), 0.8),
                textStyle(fromDuration(duree), 0.8)
              ],
            ),
            Slider(
              value:position.inSeconds.toDouble() ,
              min: 0.0,
              max: duree.inSeconds.toDouble(),
              inactiveColor: Colors.white,
              activeColor: Colors.red,
              onChanged: (double d){
                setState(() {
                  audioPlayer.seek(d);
                });
              },
            )
          ],
        ),
      ),
    );
  }
  Text textStyle(String data, double scale){
    return Text(
      data,
      textScaleFactor: scale,
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontStyle: FontStyle.italic
      ),
    );
  }

  IconButton button(IconData icone, double taille, ActionMusic action){
    return IconButton(
      iconSize: taille,
      color: Colors.white,
      icon: Icon(icone),
      onPressed: () {
        switch (action) {
          case ActionMusic.play:
            play();
          break;
          case ActionMusic.pause:
            pause();
          break;
          case ActionMusic.forward:forward();
          break;
          case ActionMusic.rewind:rewind();
          break;
        }
      },
    );
  }

  void configurationAudioPlayer() {
    audioPlayer = AudioPlayer();
    positionSub = audioPlayer.onAudioPositionChanged.listen(
            (pos) => setState(() => position = pos)
    );

    StateSubscription = audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == AudioPlayerState.PLAYING) {
        setState(() => duree = audioPlayer.duration);
      } else if (state == AudioPlayerState.STOPPED) {
        setState(() {
          status = PlayerState.stopped;
        });
      }
    }, onError: (msg) {
      print(msg);
      setState(() {
        status = PlayerState.stopped;
        duree = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });

  }
  Future<void> play() async {
    await audioPlayer.play(maMusiqueActuelle.urlSong);
    setState(() => status = PlayerState.playing);
  }

  Future<void> pause() async {
    await audioPlayer.pause();
    setState(() => status = PlayerState.paused);
  }

  void forward() {
    if(index == maListDeMusique.length - 1){
      index = 0;
    }else {
      index++;
    }
    maMusiqueActuelle = maListDeMusique[index];
    audioPlayer.stop();
    configurationAudioPlayer();
    play();
  }

  void rewind() {
    if(position > Duration(seconds: 3)){
      audioPlayer.seek(0.0);
    }else {
    if(index == 0){
      index = maListDeMusique.length - 1;
    }else {
      index--;
    }
    maMusiqueActuelle = maListDeMusique[index];
    audioPlayer.stop();
    configurationAudioPlayer();
    play();
    }
  }

  String fromDuration(Duration duree) {
    return duree.toString().split('.').first;
  }
}
enum ActionMusic {
  play,pause,forward,rewind
}
enum PlayerState {
  playing,paused,stopped
}
