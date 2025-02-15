import 'dart:async';
import 'dart:ui';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as FSTORE;
import 'package:favorite_button/favorite_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flimmerkiste/profilepage.dart';
import 'package:flutter/material.dart';
import 'package:flimmerkiste/results.dart';
import 'package:flimmerkiste/query.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:video_player/video_player.dart';

class HomePage extends StatefulWidget {
  static String tag = 'home-page';

  const HomePage({super.key});

  @override
  State<HomePage> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<HomePage> {
  final TextEditingController _controllerKeyword = TextEditingController();
  Query _query = Query();

  final List<String> channels = [
    "3SAT",
    "ARD",
    "ARTE",
    "ARTE.DE",
    "ARTE.FR",
    //"BASE",
    "BR",
    "DW",
    "Funk.net",
    "HR",
    "KIKA",
    "MDR",
    "NDR",
    "ORF",
    "PHOENIX",
    "RBTV",
    "RBB",
    "SR",
    "SRF",
    "SWR",
    "WDR",
    "ZDF",
    "ZDF-TIVI"
  ];
  Future<ResultsChannel>? _queriedDataByChannel;
  Future<ResultsChannel>? _queriedDataByKeyword;

  late String currentChannel;

  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown
        },
      ),
      home: Scaffold(
        floatingActionButton:
            !(_queriedDataByChannel == null && _queriedDataByKeyword == null)
                ? FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        _queriedDataByChannel = null;
                        _queriedDataByKeyword = null;
                      });
                    },
                    child: const Icon(Icons.home),
                  )
                : null,
        appBar: AppBar(
          title: const Text('Willkommen in der flimmerkiste.'),
          backgroundColor: Colors.black,
          titleTextStyle: const TextStyle(color: Colors.white),
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
              icon: const Icon(
                Icons.logout,
                color: Colors.redAccent,
              ),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text(
                          "Sicher, dass Sie sich abmelden wollen?",
                          textAlign: TextAlign.center,
                        ),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: [
                              GestureDetector(
                                child: const Text("Ja"),
                                onTap: () {
                                  FirebaseAuth.instance.signOut();
                                  Fluttertoast.showToast(
                                      msg: "Erfolgreich ausgeloggt!",
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 3,
                                      backgroundColor: Colors.green,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      '/', (Route<dynamic> route) => false);
                                },
                              ),
                              const Padding(padding: EdgeInsets.all(10)),
                              GestureDetector(
                                child: const Text("Nein, abbrechen"),
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    });
              }),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
          ],
        ),
        body: Stack(children: <Widget>[
          Container(
              decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/backgrounds/black_background.jpg"),
              fit: BoxFit.fill,
            ),
          )),
          Container(
            alignment: Alignment.center,
            child:
                _queriedDataByChannel == null && _queriedDataByKeyword == null
                    ? buildFutureBuilderHome()
                    : _queriedDataByChannel != null
                        ? buildFutureBuilderByChannel(currentChannel)
                        : buildFutureBuilderByKeyword(_controllerKeyword.text),
          )
        ]),
      ),
    );
  }

  TextField buildTextFieldSearch() {
    return TextField(
      controller: _controllerKeyword,
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        enabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        labelText: 'Schlagwort eingeben',
        labelStyle: TextStyle(color: Colors.white),
      ),
      onChanged: (value) => setState(() {
        if (value == "") {
          _queriedDataByKeyword = null;
        } else if (value != "") {
          if (_debounce?.isActive ?? false) _debounce?.cancel();
          _debounce = Timer(const Duration(milliseconds: 00), () {
            _queriedDataByKeyword = _query.queryByKeyword(value, 10, false);
          });
        }
      }),
      style: const TextStyle(color: Colors.white),
    );
  }

  Container buildContainerSendung(channel, snapshot, index) {
    return Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: colorBox(channel),
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black,
                colorBox(channel),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              )
            ]),
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        width: MediaQuery.of(context).size.width * 0.472,
        height: 110,
        child: InkWell(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // ignore: prefer_const_constructors
              Container(
                alignment: Alignment.topLeft,
                child: Image(
                  alignment: Alignment.topLeft,
                  image: AssetImage("assets/channels/$channel.png"),
                  width: 75,
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                child: Text(
                  getNewLineString(snapshot.data!.results[index].topic,
                      snapshot.data!.results[index].timestamp),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.normal),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => _TitleState(
                          snapshot.data!.results[index].topic,
                          snapshot.data!.results[index].title,
                          snapshot.data!.results[index].channel,
                          snapshot.data!.results[index].url_video,
                          snapshot.data!.results[index].description,
                          snapshot.data!.results[index].duration,
                          snapshot.data!.results[index].timestamp,
                        )));
          },
        ));
  }

  Container buildContainerSendungText(snapshot, index) {
    return Container(
        width: 150,
        alignment: Alignment.topLeft,
        child: InkWell(
          child: Column(
            children: [
              Text(snapshot.data!.results[index].title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.normal),
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.visible),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                textDirection: TextDirection.ltr,
                children: [
                  Icon(
                    Icons.access_time,
                    color: Colors.white,
                    size: 14,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    calculateDuration(snapshot.data!.results[index].duration),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                    //textAlign: TextAlign.start,
                  ),
                ],
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => _TitleState(
                          snapshot.data!.results[index].topic,
                          snapshot.data!.results[index].title,
                          snapshot.data!.results[index].channel,
                          snapshot.data!.results[index].url_video,
                          snapshot.data!.results[index].description,
                          snapshot.data!.results[index].duration,
                          snapshot.data!.results[index].timestamp,
                        )));
          },
        ));
  }

  SingleChildScrollView buildFutureBuilderHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          buildTextFieldSearch(),
          const SizedBox(height: 30),
          for (var channel in channels) ...[
            Container(
              width: 1200,
              alignment: Alignment.centerLeft,
              child: Text(
                channel,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.start,
              ),
            ),
            Container(
              width: 1200,
              height: 150,
              child: ListView(
                controller: ScrollController(),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                children: [
                  FutureBuilder<ResultsChannel>(
                    future: _query.queryForHomeScreen(channel, 10, false),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: snapshot.data!.results.length,
                            itemBuilder: (context, index) {
                              return buildContainerSendung(
                                  channel, snapshot, index);
                            });
                      } else if (snapshot.hasError) {
                        return Text("${snapshot.error}");
                      }
                      return const CircularProgressIndicator();
                    },
                  ),
                  FloatingActionButton(
                    child: const Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        currentChannel = channel;
                        _queriedDataByChannel =
                            _query.queryForHomeScreen(channel, 10, true);
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  SingleChildScrollView buildFutureBuilderByKeyword(String keyword) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          buildTextFieldSearch(),
          const SizedBox(height: 30),
          Container(
            width: MediaQuery.of(context).size.width * 100,
            height: 600,
            child: FutureBuilder<ResultsChannel>(
              future: _queriedDataByKeyword,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.results.length == 0) {
                    return Text(
                      "Keine Ergebnisse gefunden für: ${_controllerKeyword.text}",
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    );
                  }
                  return ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: false,
                      itemCount: snapshot.data!.results.length,
                      itemBuilder: (context, index) {
                        return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildContainerSendung(
                                  snapshot.data!.results[index].channel
                                      .toUpperCase(),
                                  snapshot,
                                  index),
                              buildContainerSendungText(snapshot, index),
                            ]);
                      });
                } else if (snapshot.hasError) {
                  print("error");
                  return Text("${snapshot.error}");
                } else {
                  print("loading");
                  return CircularProgressIndicator(); // loading
                }
              },
            ),
          ),
          FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                _queriedDataByKeyword =
                    _query.queryByKeyword(keyword, 10, true);
              });
            },
          )
        ],
      ),
    );
  }

  SingleChildScrollView buildFutureBuilderByChannel(String channel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Neueste Sendungen auf $channel",
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 100,
            height: 900,
            child: FutureBuilder<ResultsChannel>(
              future: _queriedDataByChannel,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: false,
                      itemCount: snapshot.data!.results.length,
                      itemBuilder: (context, index) {
                        return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildContainerSendung(channel, snapshot, index),
                              buildContainerSendungText(snapshot, index),
                            ]);
                      });
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return const CircularProgressIndicator();
              },
            ),
          ),
          FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                _queriedDataByChannel =
                    _query.queryForHomeScreen(channel, 10, true);
              });
            },
          ),
        ],
      ),
    );
  }
}

String calculateDuration(int duration) {
  var durationObj = Duration(seconds: duration);
  var durationString = durationObj.inMinutes.toString() +
      ":" +
      (durationObj.inSeconds % 60).toString();
  return durationString;
}

String calculateTimestamp(int timestamp) {
  var timestampDateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
  var timestampString = timestampDateTime.day.toString() +
      "." +
      timestampDateTime.month.toString() +
      "." +
      timestampDateTime.year.toString();
  return timestampString;
}

String getNewLineString(String title, int timestamp) {
  var timestampDateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
  var timestampString = timestampDateTime.day.toString() +
      "." +
      timestampDateTime.month.toString() +
      "." +
      timestampDateTime.year.toString();
  var readLines = [title, timestampString];
  StringBuffer sb = new StringBuffer();
  for (String line in readLines) {
    sb.write(line + "\n");
  }
  return sb.toString();
}

Color colorBox(String channel) {
  if (channel == "ARTE") {
    return Colors.blue;
  } else if (channel == "ZDF") {
    return Colors.blue;
  } else if (channel == "3Sat") {
    return Colors.green;
  } else if (channel == "ARTE.DE") {
    return Colors.blue;
  } else if (channel == "ARTE.FR") {
    return Colors.pink;
  } else if (channel == "BR") {
    return Colors.yellow;
  } else if (channel == "SR") {
    return Colors.purple;
  } else if (channel == "SWR") {
    return Colors.orange;
  } else if (channel == "DW") {
    return Colors.pink;
  } else if (channel == "PHOENIX") {
    return Colors.brown;
  } else if (channel == "KIKA") {
    return Colors.cyan;
  } else if (channel == "ARD") {
    return Colors.lime;
  } else if (channel == "RBB") {
    return Colors.teal;
  } else if (channel == "SRF") {
    return Colors.indigo;
  } else if (channel == "ORF") {
    return Colors.deepOrange;
  } else if (channel == "NDR") {
    return Colors.red;
  } else if (channel == "WDR") {
    return Colors.lightBlue;
  } else if (channel == "MDR") {
    return Colors.lightGreen;
  } else if (channel == "HR") {
    return Colors.amber;
  } else if (channel == "NDR") {
    return Colors.red;
  } else if (channel == "WDR") {
    return Colors.lightBlue;
  } else if (channel == "MDR") {
    return Colors.lightGreen;
  } else if (channel == "HR") {
    return Colors.amber;
  } else {
    return Colors.amber;
  }
}

class _TitleState extends StatefulWidget {
  _TitleState(
      topic, title, channel, url_video, description, duration, timestamp) {
    this.description = description;
    this.topic = topic;
    this.title = title;
    this.channel = channel;
    this.url_video = url_video;
    this.duration = duration;
    this.timestamp = timestamp;
  }

  String topic = "";
  String description = "";
  String title = "";
  String channel = "";
  String url_video = "";
  int duration = 0;
  int timestamp = 0;

  @override
  State<_TitleState> createState() => _TitleStateState();
}

class _TitleStateState extends State<_TitleState> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> initializePlayer() async {
    _videoPlayerController = VideoPlayerController.network(widget.url_video);

    await Future.wait([_videoPlayerController.initialize()]);
    _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: true);

    setState(() {});
  }

  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flimmerkiste',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              child: const Icon(Icons.home),
            ),
            appBar: AppBar(
              title: Text(widget.topic),
              backgroundColor: Colors.black,
              titleTextStyle: const TextStyle(color: Colors.white),
              iconTheme: const IconThemeData(color: Colors.white),
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfilePage()),
                    );
                  },
                ),
              ],
            ),
            body: Stack(children: <Widget>[
              Container(
                  decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/backgrounds/black_background.jpg"),
                  fit: BoxFit.fill,
                ),
              )),
              Container(
                  alignment: Alignment.center,
                  child: buildFutureBuilderByTitle(
                      widget.topic,
                      widget.channel,
                      widget.url_video,
                      widget.title,
                      widget.description,
                      widget.duration,
                      widget.timestamp,
                      _videoPlayerController,
                      _chewieController)),
            ])));
  }
}

SingleChildScrollView buildFutureBuilderByTitle(
    String topic,
    String channel,
    String url_video,
    String title,
    String description,
    int duration,
    int timestamp,
    VideoPlayerController _videoPlayerController,
    ChewieController? _chewieController) {
  return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Column(
        children: [
          Container(
            height: 270,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            alignment: Alignment.topCenter,
            child: _chewieController != null &&
                    _chewieController.videoPlayerController.value.isInitialized
                ? Chewie(
                    controller: ChewieController(
                      videoPlayerController: _videoPlayerController,
                      showOptions: false,
                      autoInitialize: true,
                      aspectRatio: 16 / 9,
                      autoPlay: false,
                      looping: false,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text('Loading'),
                    ],
                  ),
          ),
          FavoriteButton(
            valueChanged: (_isFavorite) {
              var ref = FSTORE.FirebaseFirestore.instance
                  .collection(FirebaseAuth.instance.currentUser!.uid);
              ref.get().then((docSnapshot) => {
                    if (_isFavorite == true)
                      if (docSnapshot.size == 0)
                        {
                          FSTORE.FirebaseFirestore.instance
                              .collection(
                                  FirebaseAuth.instance.currentUser!.uid)
                              .doc(channel.toUpperCase())
                              .set({
                            "title": FSTORE.FieldValue.arrayUnion([title])
                          })
                        }
                      else if (docSnapshot.docs.isEmpty)
                        {
                          FSTORE.FirebaseFirestore.instance
                              .collection(
                                  FirebaseAuth.instance.currentUser!.uid)
                              .doc(channel.toUpperCase())
                              .update({
                            "title": FSTORE.FieldValue.arrayUnion([title])
                          })
                        }
                      else
                        {
                          ref.doc(channel.toUpperCase()).set({
                            "title": FSTORE.FieldValue.arrayUnion([title])
                          })
                        }
                    else
                      {
                        ref.doc(channel.toUpperCase()).update({
                          "title": FSTORE.FieldValue.arrayRemove([title]),
                        }).then((value) {
                          ref.doc(channel.toUpperCase()).delete();
                        })
                      }
                  });
            },
          ),
          Container(
              padding: EdgeInsets.all(1),
              child: Text(
                topic,
                style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 20,
                    color: Colors.white),
                textAlign: TextAlign.center,
              )),
          SizedBox(
            height: 20,
          ),
          Container(
              padding: EdgeInsets.all(10),
              child: Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 20,
                      color: Colors.grey))),
          SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                channel,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey),
              ),
              SizedBox(
                width: 10,
              ),
              Text("|",
                  style: const TextStyle(color: Colors.grey, fontSize: 20)),
              SizedBox(
                width: 10,
              ),
              Icon(
                Icons.access_time,
                color: Colors.grey,
                size: 20,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                calculateDuration(duration),
                style: const TextStyle(color: Colors.grey, fontSize: 20),
              ),
              SizedBox(
                width: 15,
              ),
              Text("|",
                  style: const TextStyle(color: Colors.grey, fontSize: 20)),
              SizedBox(
                width: 15,
              ),
              Icon(
                Icons.calendar_today,
                color: Colors.grey,
                size: 20,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                calculateTimestamp(timestamp),
                style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 20,
                    color: Colors.grey),
              ),
            ],
          ),
          SizedBox(
            height: 30,
          ),
          Container(
            padding: EdgeInsets.all(10),
            width: 600,
            alignment: Alignment.centerLeft,
            child: Text(
              "Beschreibung:",
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                  color: Colors.white),
              textAlign: TextAlign.start,
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            width: 600,
            child: Text(
              description,
              style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 15,
                  color: Colors.white),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ));
}
