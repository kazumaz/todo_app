import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
  int counter = 0;

  @override
  void initState() {
    super.initState();
    modelList = [];
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
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: "ToDoを追加してください",
                        // hintText: "ToDoを追加してください"
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      controller: myTextController,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline),
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    modelList.add(
                        Model(title: myTextController.text, key: counter + 1));
                    setState(() {});
                    counter = counter + 1;
                    myTextController.clear();
                  },
                ),
              ],
            ),
            // Expanded or Flexivle を付与しないとエラーにな  る。
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
              children: modelList.map(
                (Model model) {
                  return Card(
                      elevation: 2.0,
                      key: Key(model.key.toString()),
                      child: Slidable(
                          actionPane: SlidableDrawerActionPane(),
                          actionExtentRatio: 0.25,
                          secondaryActions: <Widget>[
                            IconSlideAction(
                              caption: '削除',
                              color: Colors.red,
                              icon: Icons.delete,
                              onTap: () {
                                modelList.remove(model);
                                setState(() {});
                              },
                            ),
                            IconSlideAction(
                              caption: '完了',
                              color: Colors.indigo,
                              icon: Icons.done,
                              onTap: () => {},
                            ),
                          ],
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                  child: ListTile(
                                leading: const Icon(Icons.people),
                                title: Text(model.title),
                              )),
                              Container(
                                  width: 40,
                                  child: InkWell(
                                      child: Icon(
                                        Icons.remove_circle,
                                        color: Colors.redAccent,
                                      ),
                                      onTap: () {
                                        modelList.remove(model);
                                        setState(() {});
                                      }))
                            ],
                          )));
                },
              ).toList(),
            )),
          ],
        )));
  }
}

class Model {
  final String title;
  final int key;

  Model({@required this.title, @required this.key});
}
