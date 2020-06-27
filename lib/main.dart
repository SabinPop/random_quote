import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:random_quote/quote.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:random_quote/custom_tooltip.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:android_alarm_manager/android_alarm_manager.dart';


void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.grey,
      ),
      home: new MyHomePage(title: 'Daily quote'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var refreshKey = GlobalKey<RefreshIndicatorState>();

  List<Quote> list;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  @override
  initState() {
    super.initState();
    _showDailyAtTime();
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        selectNotification: onSelectNotification);
  }

  Future<Null> refreshList() async {
    refreshKey.currentState?.show(atTop: true);
    list = await fetchQuotes();

    setState(() {
      //list = fetchQuotes();
    });

    return null;
  }

  Future<List<Quote>> fetchQuotes() async{
    final response = await http.get('https://talaikis.com/api/quotes');
    if(response.statusCode == 200){
      List responseJson = json.decode(response.body.toString());
      List<Quote> quotes = createQuoteList(responseJson);
      return quotes;
    } else{
      throw Exception('Failed to load quotes');
    }
  }

  List<Quote> createQuoteList(List data){
    List<Quote> list = new List();
    for (int i = 0; i < data.length; i++) {
      String quote = data[i]['quote'];
      String author = data[i]['author'];
      String cat = data[i]['cat'];
      Quote q = new Quote(quote: quote, author: author, cat: cat);
      list.add(q);
    }
    return list;
  }

  String quote;
  String author;
  String cat;


/*
  void _refresh() {
    setState(() {
      RenderObjectWidget;
    });
  }
*/


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    final key = new GlobalKey<ScaffoldState>();
    return new Scaffold(
      key: key,
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
        centerTitle: true,
      ),
      body: RefreshIndicator(
          key: refreshKey,
          child: new Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
              child: FutureBuilder<List<Quote>>(
                future: fetchQuotes(),
                builder: (context, snapshot){
                  if(snapshot.hasData){
                    return new ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, i){
                          return new Padding
                            (
                            padding: EdgeInsets.only(
                                left: 16.0, right: 16.0, bottom: 8.0, top: 8.0),
                            child: Material
                              (
                              elevation: 10.0,
                              color: Colors.white,
                              borderRadius: BorderRadius.only
                                (
                                topRight: Radius.circular(20.0),
                                topLeft: Radius.circular(20.0),
                                bottomLeft: Radius.circular(20.0),
                                bottomRight: Radius.circular(20.0),
                              ),
                              child: Container
                                (
                                margin: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 0.0),
                                child: Container
                                  (
                                  child: ListTile
                                    (
                                    leading: Container(
                                      decoration: new BoxDecoration(),
                                      child: new RotatedBox(
                                        quarterTurns: 1,
                                        child: new Text(
                                          snapshot.data[i].cat,
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            color: Colors.black45,
                                          ),
                                        ),
                                      ),
                                    ),
                                    title: new Text(
                                        snapshot.data[i].author, style: TextStyle(fontSize: 24.0)),
                                    subtitle: new GestureDetector(
                                      child: new CustomToolTip(text: snapshot.data[i].quote),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        });
                  }
                  return new Container(
                    child: new CircularProgressIndicator(),
                  );
                },
              )
          ),
          onRefresh: refreshList
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: refreshList,
        tooltip: 'Refresh',
        child: new Icon(Icons.refresh),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future _showNotificationWithDefaultSound() async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'New Post',
      'How to Show Notification in Flutter',
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  Future _showDailyAtTime() async {
    var time = new Time(16, 0, 0);
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'repeatDailyAtTime channel id',
        'repeatDailyAtTime channel name',
        'repeatDailyAtTime description');
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.showDailyAtTime(
        0,
        'show daily title',
        'Daily notification shown at approximately nnn',
        time,
        platformChannelSpecifics);
  }

  String _toTwoDigitString(int value) {
    return value.toString().padLeft(2, '0');
  }

  Future _cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }

    await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new SecondScreen(payload)),
    );
  }
}

class SecondScreen extends StatefulWidget {
  final String payload;
  SecondScreen(this.payload);
  @override
  State<StatefulWidget> createState() => new SecondScreenState();
}

class SecondScreenState extends State<SecondScreen> {
  String _payload;
  @override
  void initState() {
    super.initState();
    _payload = widget.payload;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Second Screen with payload: " + _payload),
      ),
      body: new Center(
        child: new RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: new Text('Go back!'),
        ),
      ),
    );
  }
}