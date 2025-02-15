import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:date_time_picker/date_time_picker.dart';

Future<Results> queryData(
    [String? channel,
    String? keyword,
    double? timestamp1,
    double? timestamp2]) async {
  if (channel == "") {
    channel = null;
    print("channel = $channel");
  }
  if (keyword == "") {
    keyword = null;
    print("keyword = $keyword");
  }
  if (timestamp1 == "") {
    timestamp1 = null;
    print("timestamp1 = $timestamp1");
  }
  if (timestamp2 == "") {
    timestamp2 = null;
    print("timestamp2 = $timestamp2");
  }

  final response = await http.post(
    Uri.parse('https://mediathekviewweb.de/api/query'),
    headers: <String, String>{
      'Content-Type': 'text/plain; charset=UTF-8',
    },
    body: (channel == null && keyword == null)
        ? jsonEncode(<String, dynamic>{
            "queries": [
              {
                "fields": ["channel"],
                "query": "orf" // default channel
              }
            ],
            "sortBy": "timestamp",
            "sortOrder": "desc", //newest first
            "size": "1000"
          })
        : (channel == null)
            ? jsonEncode(<String, dynamic>{
                "queries": [
                  {
                    "fields": ["title", "topic"],
                    "query": keyword
                  }
                ],
                "sortBy": "timestamp",
                "sortOrder": "desc",
                "size": "1000"
              })
            : (keyword == null)
                ? jsonEncode(<String, dynamic>{
                    "queries": [
                      {
                        "fields": ["channel"],
                        "query": channel
                      },
                    ],
                    "sortBy": "timestamp",
                    "sortOrder": "desc",
                    "size": "1000"
                  })
                : jsonEncode(<String, dynamic>{
                    "queries": [
                      {
                        "fields": ["title", "topic"],
                        "query": keyword
                      },
                      {
                        "fields": ["channel"],
                        "query": channel
                      },
                    ],
                    "sortBy": "timestamp",
                    "sortOrder": "desc",
                    "size": "1000"
                  }),
  );
  if (response.statusCode == 200) {
    print("timestamp1 = $timestamp1");
    print("timestamp2 = $timestamp2");
    return Results.fromJson(
        json: jsonDecode(response.body),
        timestamp1: timestamp1,
        timestamp2: timestamp2);
  } else {
    throw Exception('Failed to load data');
  }
}

class Results {
  List<Result> results = [];

  Results({required this.results});
  Results.fromJson(
      {Map<String, dynamic>? json, double? timestamp1, double? timestamp2}) {
    json!["result"]["results"].forEach((list) {
      if (timestamp1 == null && timestamp2 == null) {
        print("added 1");
        results.add(Result.fromJson(list));
      } else if (timestamp1 == null) {
        timestamp2 = timestamp2! / 1000;
        if (list["timestamp"] <= timestamp2) {
          print("added 2");
          results.add(Result.fromJson(list));
        }
      } else if (timestamp2 == null) {
        timestamp1 = timestamp1! / 1000;
        if (list["timestamp"] >= timestamp1) {
          print("added 3");
          results.add(Result.fromJson(list));
        }
      } else {
        double timestamp = list["timestamp"] * 1000;
        print("timestamp = $timestamp");
        print("timestamp1 = $timestamp1");
        print("timestamp2 = $timestamp2");
        if (timestamp >= timestamp1! && timestamp <= timestamp2!) {
          print("added 4");
          print("timestamp1 = $timestamp1");
          print("timestamp = ${list["timestamp"]}");
          print("timestamp2 = $timestamp2");
          results.add(Result.fromJson(list));
        }
      }
    });
  }
}

class Result {
  String topic = '';
  String title = '';
  String channel = '';
  String url_video = '';
  int timestamp = 0;

  Result({required this.title, required this.channel});
  Result.fromJson(Map<String, dynamic> json) {
    topic = json['topic'];
    title = json['title'];
    channel = json['channel'];
    url_video = json['url_video'];
    timestamp = json['timestamp'] * 1000;
    print("class result = $title, $channel, $topic");
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _controllerChannel = TextEditingController();
  final TextEditingController _controllerKeyword = TextEditingController();
  final TextEditingController _controllerTimestamp = TextEditingController();
  final TextEditingController _controllerTimestamp2 = TextEditingController();

  final List<String> channels = [
    "ARD",
    "ARTE",
    "BASE",
    "BR",
    "DREISAT",
    "DW",
    "KIKA",
    "ORF",
    "PHOENIX",
    "SR",
    "SRF",
    "SWR",
    "ZDF"
  ];

  Future<Results>? _queriedData;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Query Data from MediathekViewWeb',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Query Data from MediathekViewWeb'),
          leading: (_queriedData == null)
              ? const Icon(Icons.logout)
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _queriedData = null;
                    });
                  },
                ),
        ),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: (_queriedData == null) ? buildColumn() : buildFutureBuilder(),
        ),
      ),
    );
  }

  Column buildColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        DropdownButtonFormField(
          decoration: const InputDecoration(hintText: 'Select Channel'),
          items: channels.map((String dropDownStringItem) {
            return DropdownMenuItem<String>(
              value: dropDownStringItem,
              child: Text(dropDownStringItem),
            );
          }).toList(),
          onChanged: (String? newValueSelected) {
            setState(() {
              this._controllerChannel.text = newValueSelected!;
            });
          },
        ),
        TextField(
          controller: _controllerChannel,
          decoration: const InputDecoration(hintText: 'Enter Channel'),
        ),
        TextField(
          controller: _controllerKeyword,
          decoration: const InputDecoration(hintText: 'Enter Keyword'),
        ),
        DateTimePicker(
          type: DateTimePickerType.dateTimeSeparate,
          controller: _controllerTimestamp,
          dateMask: 'd MMM, yyyy',
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          icon: const Icon(Icons.event),
          dateLabelText: 'From: Date',
          timeLabelText: "Hour",
          onChanged: (val) =>
              print("Controller = " + _controllerTimestamp.text),
          validator: (val) {
            print(val);
            print("Controller = " + _controllerTimestamp.text);
            return null;
          },
          onSaved: (val) => print("Controller = " + _controllerTimestamp.text),
        ),
        DateTimePicker(
          type: DateTimePickerType.dateTimeSeparate,
          controller: _controllerTimestamp2,
          dateMask: 'd MMM, yyyy',
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          icon: const Icon(Icons.event),
          dateLabelText: 'To: Date',
          timeLabelText: "Hour",
          onChanged: (val) => print(val),
          validator: (val) {
            print("val = $val");
          },
          onSaved: (val) => print("saved"),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              if (_controllerTimestamp.text.isEmpty &&
                  _controllerTimestamp2.text.isEmpty) {
                print("empty");
                _queriedData =
                    queryData(_controllerChannel.text, _controllerKeyword.text);
              } else if (_controllerTimestamp.text.isEmpty) {
                print("empty 1");
                _queriedData = queryData(
                    _controllerChannel.text,
                    _controllerKeyword.text,
                    null,
                    DateTime.parse(_controllerTimestamp2.text)
                        .millisecondsSinceEpoch
                        .toDouble());
              } else if (_controllerTimestamp2.text.isEmpty) {
                print("empty 2");
                _queriedData = queryData(
                    _controllerChannel.text,
                    _controllerKeyword.text,
                    DateTime.parse(_controllerTimestamp.text)
                        .millisecondsSinceEpoch
                        .toDouble(),
                    null);
              } else {
                print("not empty");
                _queriedData = queryData(
                    _controllerChannel.text,
                    _controllerKeyword.text,
                    DateTime.parse(_controllerTimestamp.text)
                        .millisecondsSinceEpoch
                        .toDouble(),
                    DateTime.parse(_controllerTimestamp2.text)
                        .millisecondsSinceEpoch
                        .toDouble());
              }
            });
          },
          child: const Text('Query Data'),
        ),
      ],
    );
  }

  FutureBuilder<Results> buildFutureBuilder() {
    return FutureBuilder<Results>(
      future: _queriedData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          print("Data: ${snapshot.data!.results.length}");
          return ListView.builder(
            itemCount: snapshot.data!.results.length,
            itemBuilder: (context, index) {
              if (snapshot.data!.results.isEmpty) {
                print("No Data");
                return const Text("No Data"); // NOT WORKING
              } else {
                return ListTile(
                  //leading: Text(snapshot.data!.results[index].topic),
                  title: Text(snapshot.data!.results[index].title),
                  subtitle: Text(
                      "${DateTime.fromMillisecondsSinceEpoch(snapshot.data!.results[index].timestamp)} - ${snapshot.data!.results[index].channel}"),
                  //trailing: Text(snapshot.data!.results[index].url_video),
                );
              }
            },
          );
        } else if (snapshot.hasError) {
          print("Error: ${snapshot.error}");
          return Text('${snapshot.error}');
        }

        return const CircularProgressIndicator();
      },
    );
  }
}
