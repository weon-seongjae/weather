import 'package:flutter/material.dart';
import './style.dart' as style;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


void main() {
  runApp(MaterialApp(
      theme : style.theme,
      home: MyApp(),
      )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  var tab = 0;
  var userImage;
  List<dynamic> data = [];
  List<dynamic> data2 = [];

  getData() async {
      var result = await http.get(Uri.parse('https://codingapple1.github.io/app/data.json'));
      var result2 = jsonDecode(result.body);

      setState(() {
        data = result2;
      });
  }

  bool hasLoadedAdditionalData = false;

  getData2() async {
    if (!hasLoadedAdditionalData) {
      var result3 = await http.get(
          Uri.parse('https://codingapple1.github.io/app/more1.json'));
      var result4 = jsonDecode(result3.body);
      print('result4 $result4');
      setState(() {
        data.add(result4);
        hasLoadedAdditionalData = true;
      });
    }
  }

  void loadMore() {
    getData2();
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title : Text('Keystagram'),
          actions: [
            IconButton(
              onPressed: (){},
              icon: Icon(Icons.add_box_outlined),
              iconSize: 30
            )
          ]
        ),
      body: [Body(data: data, loadMore: loadMore, hasLoadedAdditionalData: hasLoadedAdditionalData), Text('샵페이지')][tab],
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (i) {setState(() {
            tab = i;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              label: 'Shop',
          ),
        ],
      ),
    );
  }

  upload() {}
}

class Body extends StatefulWidget {
  const Body({Key? key, required this.data, required this.loadMore, required this.hasLoadedAdditionalData}) : super(key: key);
  final List<dynamic> data;
  // final List<dynamic> data2;
  final Function loadMore;
  final bool hasLoadedAdditionalData;

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {

  var scroll = ScrollController();
  bool hasLoadedAdditionalData = false;
  @override
  void initState() {
    super.initState();
    scroll.addListener(() {
      if (scroll.position.pixels == scroll.position.maxScrollExtent) {
        widget.loadMore();
      }
    });
  }

  @override
    Widget build(BuildContext context) {
      if (widget.data.isNotEmpty) {
        return ListView.builder(
            itemCount: widget.data.length,
            controller: scroll,
            itemBuilder: (c, i) {
            // int actualIndex = i % widget.data.length;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(widget.data[i]['image']),
              Text("좋아요 ${widget.data[i]['likes'].toString()}"),
              Text(widget.data[i]['user']),
              Text(widget.data[i]['content']),
            ],
          );
        });
      } else { return CircularProgressIndicator(); }
  }
}




