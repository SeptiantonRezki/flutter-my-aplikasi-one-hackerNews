import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:test_belajar_bloc/src/article.dart';

void main() {
  test('test json data', () async {
    final url = 'https://hacker-news.firebaseio.com/v0/item/beststories.json';
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final idList = json.decode(res.body);
      if (idList.isNotEmpty) {
        final storyUrl =
            'https://hacker-news.firebaseio.com/v0/item/${idList.first}.json';
        final storyRes = await http.get(storyUrl);
        if (storyRes.statusCode == 200) {
          expect(parseArticle(storyRes.body), isNotNull);
        }
      }
    }
  }, skip: true);
}
