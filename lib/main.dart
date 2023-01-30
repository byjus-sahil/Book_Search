import 'dart:convert';

import 'package:book_search/books_dao.dart';
import 'package:easy_search_bar/easy_search_bar.dart';
import 'package:flutter/material.dart';

import 'bookDescription.dart';
import 'package:http/http.dart' as http;
import 'books_dao.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Search',
      home: front(),
    );
  }
}

class front extends StatefulWidget {
  const front({super.key});

  @override
  State<front> createState() => _frontState();
}

class _frontState extends State<front> {
  List<booksDao> books = [];

  // String url = "";
  bool flag = false;
  Future<List<booksDao>> getRequest(String url) async {
    books.clear();
    final response = await http.get(Uri.parse(url));

    var responseData = json.decode(response.body);

    var booksData = responseData['items'];

    for (var book in booksData) {
      var author = "";
      var publisher = "";
      var volume_info = book['volumeInfo'];
      var url2 = "";
      var imglks;
      var self_link = book['selfLink'];
      var title = "";
      if (volume_info.containsKey('imageLinks')) {
        imglks = volume_info['imageLinks'];
        if (imglks.containsKey('smallThumbnail'))
          url2 = imglks['smallThumbnail'];
        title = book['volumeInfo']['title'];
      }
      if (volume_info.containsKey('authors'))
        author = book['volumeInfo']['authors'][0];

      if (volume_info.containsKey('publisher'))
        publisher = volume_info['publisher'];

      var lang = book['volumeInfo']['language'];

      //Default values
      if (title == "") title = "Title Not available";
      if (author == "") author = "Author Not available";
      if (publisher == "") publisher = "Publisher Not available";
      if (lang == "") lang = "Language Not available";

      booksDao one_book = booksDao(
          photo_url: url2,
          title: title,
          author: author,
          publisher: publisher,
          language: lang,
          self_link: self_link);

      books.add(one_book);
    }
    return books;
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();

    getRequest(
            "https://www.googleapis.com/books/v1/volumes?q=flowers&startIndex=20")
        .then((List<booksDao> books) {
      setState(() {
        flag = true;
        print(books[0].title);
      });
    });
  }

  String query = "flower";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EasySearchBar(
          title: Text('Book Search'),
          onSearch: (value) => setState(() {
                String s = "";
                String s1 = "https://www.googleapis.com/books/v1/volumes?q=";
                String s2 = "&startIndex=20";
                //url made from search query
                s = s1 + value + s2;

                getRequest(s).then((value) {
                  setState(() {
                    books = value;

                    print(books[0].title);
                  });
                });
              })),
      body: flag
          ? Container(
              height: double.infinity,
              width: double.infinity,
              child: ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: <Widget>[
                        SizedBox(
                          height: double.minPositive,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => bookDescription(
                                index: books[index].self_link,
                              ),
                            ));
                          },
                          child: Container(
                            width: double.infinity,
                            height: 200,
                            child: Row(
                              children: [
                                Container(
                                    width: 180,
                                    child:
                                        Image.network(books[index].photo_url)),
                                Expanded(
                                  child: Container(
                                    color: Colors.lightBlue[100],
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          books[index].title.length > 40
                                              ? books[index]
                                                      .title
                                                      .substring(0, 40) +
                                                  "..."
                                              : books[index].title,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "Author: " + books[index].author,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "Publisher: " +
                                              books[index].publisher,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "Language: " + books[index].language,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    );
                  }),
            )
          : Container(
              height: double.infinity,
              width: double.infinity,
            ),
    );
  }
}
