import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter ReorderableListView',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'ReorderableListView Sample'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Model> modelList;
  final myTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    modelList = [];
    List<String> titleList = ["Title A", "Title B", "Title C"];    
    for (int i = 0; i < 3; i++) {
      Model model = Model(
        title: titleList[i],
        key: i.toString(),
      );
      modelList.add(model);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Container(
            child: Column(
          children: <Widget>[          
              Padding(
              padding: const EdgeInsets.all(16.0),
              child: 
              TextField(
                decoration: InputDecoration(
                    labelText: "Description",
                    hintText: "ex) read one book about Flutter"),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                controller: myTextController,
              ),
            ) ,         
            // Expanded or Flexivle を付与しないとエラーになる。
            // [https://github.com/flutter/flutter/issues/17036]
            
            Flexible(
                child: ReorderableListView(
              padding: EdgeInsets.all(10.0),  
              onReorder: (oldIndex, newIndex) {
                if (oldIndex < newIndex) {
                  // removing the item at oldIndex will shorten the list by 1.
                  newIndex -= 1;
                }
                final Model model = modelList.removeAt(oldIndex);

                setState(() {
                  modelList.insert(newIndex, model);
                });
              },
              children: 
              modelList.map(
                (Model model) {
                  return Card(
                    elevation: 2.0,
                    key: Key(model.key),
                    child: ListTile(
                      leading: const Icon(Icons.people),
                      title: Text(model.title),
                    ),
                  );
                },
              ).toList(),
            )),
          ],
        )));
  }
}

class Model {
  final String title;
  final String key;

  Model({
    @required this.title,
    @required this.key
  });
}
