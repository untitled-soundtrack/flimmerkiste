class ResultsChannel {
  List<ResultChannel> results = [];

  ResultsChannel({required this.results});
  ResultsChannel.fromJson({Map<String, dynamic>? json}) {
    json!["result"]["results"].forEach((list) {
      results.add(ResultChannel.fromJson(list));
      //print("class results = $list");
    });
  }
}

class ResultChannel {
  String topic = '';
  String title = '';
  String channel = '';
  String url_video = '';
  int timestamp = 0;
  int duration = 0;
  String description = '';

  ResultChannel({required this.title, required this.channel});
  ResultChannel.fromJson(Map<String, dynamic> json) {
    if (json['timestamp'] == "") {
      json['timestamp'] = 0;
    } else if (json['duration'] == "") {
      json['duration'] = 0;
    }

    topic = json['topic'];
    title = json['title'];
    channel = json['channel'];
    url_video = json['url_video'];
    timestamp = int.parse(json['filmlisteTimestamp']) * 1000;
    duration = json['duration'];
    description = json['description'];

    //print("class result = $title, $channel, $topic");
  }
}
