import 'dart:convert' as json;
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:test_belajar_bloc/src/serializers.dart';

part 'article.g.dart';

abstract class Article implements Built<Article, ArticleBuilder> {
  static Serializer<Article> get serializer => _$articleSerializer;
  int get id;

  String get type;

  String get by;

  BuiltList<int> get kids; // dimana list ini nilainya nanti tidak bisa dirubah

  BuiltList<int> get parts;

  @nullable
  bool get deleted;

  @nullable
  int get time;

  @nullable
  String get text;

  @nullable
  bool get dead;

  @nullable
  int get parent;

  @nullable
  int get poll;

  @nullable
  String get url;

  @nullable
  int get score;

  @nullable
  String get title;

  @nullable
  int get descendants;

  Article._();
  factory Article([update(ArticleBuilder b)]) = _$Article;
}

List<int> parseTopString(String jsonStr) {
  // return null;
  final parsed = json.jsonDecode(jsonStr);
  final listOfIds = List<int>.from(parsed);
  return listOfIds;
}

Article parseArticle(String jsonStr) {
  // return null;
  final parsed = json.jsonDecode(jsonStr);
  // Article article = Article.fromJson(parsed); => awalnya begini
  Article article = standartSerializers.deserializeWith(
      Article.serializer, parsed); // jadi begini
  return article;
}
