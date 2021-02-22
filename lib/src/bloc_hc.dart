import 'dart:async';
import 'dart:collection';

import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:test_belajar_bloc/src/article.dart';
import 'package:test_belajar_bloc/utils/api-response.dart';

enum StoriesType { topStories, newStories }

class HackerNewsBloc {
  static List<int> _newIds = [
    25887373,
    25916513,
    25910400,
    25888249,
    25897736,
  ];
  static List<int> _topIds = [
    25891464,
    25906792,
    25899286,
    25903259,
    25907356,
    25904965,
  ];

  static const _baseUrl = 'https://hacker-news.firebaseio.com/v0/';
  // hash map digunakan untuk menampilkan data lebih cepat => cara mencached data
  HashMap<int, Article> _cachedArticles;
  // Map<String, dynamic> _articles = Map<String, dynamic>();
  // nilai yang dirubah dan yang akan dikirimkan ke UI
  var _articles = <Article>[];
  //
  final _articlesSubject = BehaviorSubject<ApiResponse>();
  final _storiesTypeController = StreamController<StoriesType>();

  // untuk mendapatkan nilai yang masuk => sehingga tidak private
  Sink<StoriesType> get storiesType => _storiesTypeController.sink;

  // menyalurkan nilai keluar => sehingga tidak private
  Stream<ApiResponse> get articles => _articlesSubject; //untuk process Loading

  HackerNewsBloc() {
    _cachedArticles = HashMap<int, Article>();
    // karena method ini sudah menggunakan async await, maka nantinya akan tetap dijalankan
    _getArticleAndUpdate(_topIds);

    _storiesTypeController.stream.listen((storiesType) async {
      _getArticleAndUpdate(await _getIds(storiesType));
    });
  }

  Future<void> initializeArticles() async {
    _getArticleAndUpdate(await _getIds(StoriesType.topStories));
  }

  Future<List<int>> _getIds(StoriesType type) async {
    final partUrl = type == StoriesType.topStories ? 'top' : 'new';
    final url = '$_baseUrl${partUrl}stories.json';
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return parseTopString(response.body).take(10).toList();
    }
    throw ApiResponse.error("Stories $type couldn't be fatched");
  }

  Future<Article> _getArticle(int id) async {
    if (!_cachedArticles.containsKey(id)) {
      final storyUrl = '${_baseUrl}item/$id.json';
      final storyRes = await http.get(storyUrl);
      if (storyRes.statusCode == 200) {
        _cachedArticles[id] = parseArticle(storyRes.body);
      } else {
        throw ApiResponse.error("Article $id couldn't be fatched");
      }
    }
    return _cachedArticles[id];
  }

  _getArticleAndUpdate(List<int> ids) {
    // berarti untk provider memakai then,.. nantinya kalau pingin update ya ditaruh di then,.. seperti ini
    _articlesSubject.add(ApiResponse.loading('menunggu data masuk'));
    // _articlesSubjectList.add(UnmodifiableListView(_articles));  //harusnya ini tidak karena nanti langsung diproses dibawah
    _updateArticles(ids).then((_) {
      // ** untuk yang loading
      _articlesSubject.add(ApiResponse.completed(
          _articles)); // ganti dengan data UnmodifiableListView(_articles) => tidak bisa dirubah oleh user
    }).catchError((e) {
      _articlesSubject.add(ApiResponse.error(e.toString()));
    });
  }

  Future<Null> _updateArticles(List<int> ids) async {
    final futureArticle = ids.map((e) => _getArticle(e));
    final articles = await Future.wait(futureArticle);
    _articles = articles;
  }

  void close() {
    _storiesTypeController.close();
  }
}
