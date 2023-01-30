import 'dart:convert';

import 'package:flutter/material.dart';
import 'bookDescription_dao.dart';
import 'package:http/http.dart' as http;

class bookDescription extends StatefulWidget {
  final String index;

  bookDescription({super.key, required this.index});

  @override
  State<bookDescription> createState() => _bookDescriptionState();
}

class _bookDescriptionState extends State<bookDescription> {
  List<booksDescription_dao> details = [];
  bool flag = false;
  var imglks = "";
  var title = "";
  String description = "";
  Future<List<String>> getRequest() async {
    List<String> data = [];

    String url = widget.index;
    final response = await http.get(Uri.parse(url));

    var responseData = json.decode(response.body);
    var booksData = responseData['items'];

    var volume_info = responseData['volumeInfo'];

    imglks = volume_info['imageLinks']['thumbnail'];
    String description = volume_info['description'];

    title = volume_info['title'];

    booksDescription_dao one_book = booksDescription_dao(
        photo_url: url, title: title, description: description);

    data.add(title);
    data.add(description);
    data.add(imglks);
    return data;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getRequest().then((value) {
      setState(() {
        title = value[0];
        description = value[1];
        var imglks = "https" + value[2].substring(4);

        print(imglks);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print(widget.index);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Container(
        height: double.minPositive,
        width: double.infinity,
        child: Column(children: [
          (imglks != "") ? Image.network(imglks) : Container(),
          SizedBox(
            height: 10,
          ),
          Container(
            child: Column(children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[800],
                ),
              ),
            ]),
          )
        ]),
      ),
    );
  }
}
