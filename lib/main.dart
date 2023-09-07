// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:instagram/firebase_options.dart';
import 'package:instagram/notification.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';



// Notification을 위한 StreamController 전역 변수 선언
StreamController<String> streamController = StreamController.broadcast();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterLocalNotification.onBackgroundNotificationResponse();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (c) => Store1()),
      ChangeNotifierProvider(create: (c) => Store2()),
    ],
    child: MaterialApp(
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green[700]),
      home: MyApp(),
    ),
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    FlutterLocalNotification.init();

    Future.delayed(const Duration(seconds: 3),
      FlutterLocalNotification.requestNotificationPermission()
    );
    super.initState();
  }

  @override
  void dispose() {
    streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<String>(
        stream: streamController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == 'HELLOWORLD') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                  return const SecondPage();
                }));
              });
            }
          }
          return Center(
            child: TextButton(
              onPressed: () {
                FlutterLocalNotification.showNotification();
              },
              child: const Text('알림 보내기'),
            )
          );
        },
      )
    );
  }
}

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text('SECOND PAGE'),
      ),
      body: const Center(
        child: Text('SECOND PAGE'),
      ),
    );
  }
}


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var tab = 0;
  List<dynamic> data = [];
  var userImage;
  var userContent;

  saveData() async {
    // 자료 저장
    var storage = await SharedPreferences.getInstance();
    // storage.setString('name', 'john');
    // storage.setBool('bool', true);
    // storage.setStringList('list', ['dsf', 'dasfd']);
    // var result = storage.get('name');
    // print(result);
    //자료 삭제
    // storage.remove('name');
    //map 자료 저장
    var map = {'age': 20};
    storage.setString('map', jsonEncode(map));
    //map 자료 추출
    var mapResultOpen = storage.getString('map') ?? '없어요.';
    print(jsonDecode(mapResultOpen)['age']);
  }

  addMyData() {
    var myData = {
      'id': data.length,
      'image': userImage,
      'likes': 5,
      'date': 'July 25',
      'content': userContent,
      'liked': false,
      'user': 'Sj Kim',
    };
    setState(() {
      data.insert(0, myData);
    });
  }

  setUserContent(a) {
    setState(() {
      userContent = a;
    });
  }

  getData() async {
    var result = await http.get(
      Uri.parse('https://codingapple1.github.io/app/data.json'),
    );
    var result2 = jsonDecode(result.body);
    // print(result2);

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
      // print('result4 $result4');
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
    getData();
    saveData();
    FlutterLocalNotification.init();
    Future.delayed(const Duration(seconds: 3),
        FlutterLocalNotification.requestNotificationPermission());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Keystagram'),
        actions: [
          TextButton(
              onPressed: (){
                FlutterLocalNotification.showNotification();
              },
              child: Text('알림보내기')
          ),
          IconButton(
            onPressed: () async {
              var picker = ImagePicker();
              var image = await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                setState(() {
                  userImage = File(image.path);
                });
              }

              Navigator.push(
                context,
                  MaterialPageRoute(
                      builder: (c) => Upload(
                          userImage: userImage,
                          setUserContent: setUserContent,
                          addMyData: addMyData)));
            },
            icon: Icon(Icons.add_box_outlined),
            iconSize: 30,
          ),
        ],
      ),
      body: [Body(
        data: data,
        loadMore: loadMore,
        hasLoadedAdditionalData: hasLoadedAdditionalData,
      ), Text('샵페이지')][tab],
        
      bottomNavigationBar: BottomNavigationBar(
        onTap: (i) {
          setState(() {
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
}

class Upload extends StatelessWidget {

  const Upload(
      {Key? key,
      required this.userImage,
      required this.setUserContent,
      required this.addMyData})
      : super(key: key);
  final userImage;
  final Function setUserContent;
  final addMyData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Keystagram'),
        actions: [
          IconButton(
              onPressed: () {
                addMyData();
              },
              icon: Icon(Icons.send))
        ],
      ),
      body: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.file(userImage),
            TextField(
            onChanged: (text) {
              setUserContent(text);
            },
          ),
          Text('이미지업로드화면'),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.close),
            ),
        ],
      ),
      );
  }
}

class Body extends StatefulWidget {
  const Body(
      {Key? key,
      required this.data,
      required this.loadMore,
      required this.hasLoadedAdditionalData})
      : super(key: key);
  final List<dynamic> data;
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
              children: <Widget>[
                widget.data[i]['image'].runtimeType == String
                    ? Image.network(widget.data[i]['image'])
                    : Image.file(widget.data[i]['image']),
                Text("좋아요 ${widget.data[i]['likes'].toString()}"),
                GestureDetector(
                  child: Text(widget.data[i]['user']),
                  onTap: () {
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder: (ctx, a1, a2) => Profile(),
                            transitionsBuilder: (ctx, a1, a2, child) =>
                                FadeTransition(opacity: a1, child: child),
                            transitionDuration: Duration(milliseconds: 500)));
                  },
                ),
                Text(widget.data[i]['content']),

              ],
            );
          }
          );
    } else { return CircularProgressIndicator(); }
  }
}

class Store1 extends ChangeNotifier {
  var name = 'john kim';
  List<dynamic> profileImage = [];

  changeName() {
    name = 'john park';
    notifyListeners(); //재렌더링
  }

  collectImage() async {
    var getImage = await http.get(
        Uri.parse('https://codingapple1.github.io/app/profile.json')
    );
    var resultImage = jsonDecode(getImage.body);

    profileImage = resultImage;
    notifyListeners();
  }
}

class Store2 extends ChangeNotifier {
  int fCheck = 0;

  var friend = false;

  checkFollow() {
    if (!friend) {
      fCheck++;
      friend = true;
    } else {
      fCheck--;
      friend = false;
    }
    notifyListeners();
  }
}

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // SizedBox(width: 50),
              Text(context.watch<Store1>().name),
            ],
          ),
        ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ProfileHeader(),
          ),
          SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (c, i) => Image.network(context.watch<Store1>().profileImage[i]),
              childCount: context.read<Store1>().profileImage.length,
            ),
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          )
        ],
      ),
    );
  }
}

class ProfileHeader extends StatefulWidget {
  const ProfileHeader({super.key});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {

  @override
  void initState() {
    super.initState();
    context.read<Store1>().collectImage();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        CircleAvatar(radius: 30, backgroundColor: Colors.grey),
        Text('팔로워 ${context.watch<Store2>().fCheck} 명'),
        ElevatedButton(
            onPressed: () {
              context.read<Store2>().checkFollow();
            },
            child: Text('팔로우')),
        // ElevatedButton(
        //   onPressed: () {
        //     context.read<Store1>().collectImage();
        //   },
        //   child: Text('사진가져오기'),
        // )
      ],
    );
  }
}


