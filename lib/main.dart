import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:test_belajar_bloc/src/article.dart';
import 'package:test_belajar_bloc/src/bloc_hc.dart';
import 'package:test_belajar_bloc/utils/api-response.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  final hcBloc = HackerNewsBloc();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(bloc: hcBloc),
    ),
  );
}

class MyApp extends StatefulWidget {
  final HackerNewsBloc bloc;
  MyApp({Key key, this.bloc}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ListView _createListView(List<Article> dataList) {
    return ListView.builder(
      itemCount: dataList.length,
      itemBuilder: (context, index) {
        return Padding(
            key: Key(dataList[index].title ?? '[null]'),
            padding: const EdgeInsets.all(10),
            child: ExpansionTile(
              title: Text(dataList[index].title ?? '[null]'),
              children: <Widget>[
                Text('${dataList[index].descendants} comments'),
                IconButton(
                    icon: Icon(Icons.launch),
                    onPressed: () async {
                      if (await canLaunch(dataList[index].url)) {
                        launch(dataList[index].url);
                      }
                    })
              ],
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Flutter Hacker News',
          textAlign: TextAlign.center,
        ),
        elevation: 0.0,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ArticleSearch(widget.bloc.articles),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<ApiResponse>(
        stream: widget.bloc.articles,
        initialData: ApiResponse.loading('masih dalam data'),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            switch (snapshot.data.status) {
              case Status.LOADING:
                return Loading(
                  loadingMessage: snapshot.data.message,
                );
                break;
              case Status.COMPLETED:
                return _createListView(snapshot.data.data);
                break;
              case Status.ERROR:
                return Error(
                  errorMessage: snapshot.data.message,
                  onRetryPressed: () => null,
                );
                break;
            }
          } else {
            return Container();
          }
          ;
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: [
          BottomNavigationBarItem(
            label: 'Top Series',
            icon: Icon(Icons.arrow_drop_up),
          ),
          BottomNavigationBarItem(
            label: 'New Series',
            icon: Icon(Icons.new_releases),
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            widget.bloc.storiesType.add(StoriesType.topStories);
          } else {
            widget.bloc.storiesType.add(StoriesType.newStories);
          }
        },
      ),
    );
  }
}

class ArticleSearch extends SearchDelegate<Article> {
  final Stream<ApiResponse> articles;

  ArticleSearch(this.articles);
  ListView _createListView(List<Article> dataList) {
    return ListView.builder(
      itemCount: dataList.length,
      itemBuilder: (context, index) {
        return Padding(
            key: Key(dataList[index].title ?? '[null]'),
            padding: const EdgeInsets.all(10),
            child: ExpansionTile(
              title: Text(dataList[index].title ?? '[null]'),
              children: <Widget>[
                Text('${dataList[index].descendants} comments'),
                IconButton(
                    icon: Icon(Icons.launch),
                    onPressed: () async {
                      if (await canLaunch(dataList[index].url)) {
                        launch(dataList[index].url);
                      }
                    })
              ],
            ));
      },
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.search),
        onPressed: () {},
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        query = '';
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // print(articles.isEmpty);
    // return StreamBuilder<UnmodifiableListView<Article>>(
    //   stream: articles,
    //   builder:
    //       (context, AsyncSnapshot<UnmodifiableListView<Article>> snapshot) {
    //     if (!snapshot.hasData) {
    //       return Container(
    //         child: Center(
    //           child: Text('No Data'),
    //         ),
    //       );
    //     }
    //     return ListView(
    //       children: snapshot.data.map<Widget>((e) => Text(e.text)).toList(),
    //     );
    //   },
    // );
    return StreamBuilder<ApiResponse>(
        stream: articles,
        initialData: ApiResponse.loading('masih dalam data'),
        builder: (context, AsyncSnapshot<ApiResponse> snapshot) {
          if (snapshot.hasData) {
            switch (snapshot.data.status) {
              case Status.LOADING:
                return Loading(
                  loadingMessage: snapshot.data.message,
                );
                break;
              case Status.COMPLETED:
                return _createListView(snapshot.data.data);
                break;
              case Status.ERROR:
                return Error(
                  errorMessage: snapshot.data.message,
                  onRetryPressed: () => null,
                );
                break;
            }
          } else {
            return Container();
          }
        });
  }
}

class Loading extends StatelessWidget {
  final String loadingMessage;

  const Loading({Key key, this.loadingMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            loadingMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.lightGreen,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 24),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.lightGreen),
          ),
        ],
      ),
    );
  }
}

class Error extends StatelessWidget {
  final String errorMessage;

  final Function onRetryPressed;

  const Error({Key key, this.errorMessage, this.onRetryPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.lightGreen,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          RaisedButton(
            color: Colors.lightGreen,
            child: Text('Retry', style: TextStyle(color: Colors.white)),
            onPressed: onRetryPressed,
          )
        ],
      ),
    );
  }
}
