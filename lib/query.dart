import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flimmerkiste/results.dart';

class Query {
  int sizeOrigHome = 0;

  Future<ResultsChannel> queryForHomeScreen(
      String channel, int size, bool loadMore) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch * 1000;

    if (loadMore) {
      sizeOrigHome = sizeOrigHome + size;
    } else {
      sizeOrigHome = size;
    }

    final response =
        await http.post(Uri.parse('https://mediathekviewweb.de/api/query'),
            headers: <String, String>{
              'Content-Type': 'text/plain; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              "queries": [
                {
                  "fields": ["channel"],
                  "query": channel // default channel
                }
              ],
              "sortBy": "filmlisteTimestamp",
              "sortOrder": "desc",
              "size": sizeOrigHome
            }));

    if (response.statusCode == 200) {
      return ResultsChannel.fromJson(json: jsonDecode(response.body));
    } else {
      throw Exception('Failed to load data');
    }
  }

  int sizeOrig = 0;

  Future<ResultsChannel> queryByKeyword(
      String keyword, int size, bool loadMore) async {
    /* if (sizeOrig == 0) {
      sizeOrig = 10;
    } else if (sizeOrig > 0) {
      sizeOrig = sizeOrig + 10;
      size = sizeOrig;
    }*/

    if (loadMore) {
      sizeOrig = sizeOrig + size;
    } else {
      sizeOrig = size;
    }

    final response =
        await http.post(Uri.parse('https://mediathekviewweb.de/api/query'),
            headers: <String, String>{
              'Content-Type': 'text/plain; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              "queries": [
                {
                  "fields": ["title", "keyword"],
                  "query": keyword // default channel
                }
              ],
              "sortBy": "filmlisteTimestamp",
              "sortOrder": "desc",
              "offset": "0", //newest first
              "size": sizeOrig
            }));

    if (response.statusCode == 200) {
      return ResultsChannel.fromJson(json: jsonDecode(response.body));
    } else {
      throw Exception('Failed to load data');
    }
  }
}
