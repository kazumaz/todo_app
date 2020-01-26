import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'やること',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'やること'),
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
        persistentFooterButtons: <Widget>[
          RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            color: Theme.of(context).primaryColor,
            child: Text('完了済を削除'),
            onPressed: () async {
              var result = await showDialog<int>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('確認'),
                    content: Text('本当に完了済の「やること」を削除しますか？'),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(0),
                      ),
                      FlatButton(
                        child: Text('OK'),
                        onPressed: () {
                          modelList.forEach((model) {
                            if (model.done == true) {
                              modelList.remove(model);
                            }
                          });

                          setState(() {});
                          Navigator.of(context).pop(1);
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            color: Theme.of(context).primaryColor,
            child: Text('全て削除'),
            onPressed: () async {
              var result = await showDialog<int>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('確認'),
                    content: Text('本当に全ての「やること」を削除しますか？'),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(0),
                      ),
                      FlatButton(
                        child: Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop(1);
                          modelList = [];
                          setState(() {});
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
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
                        labelText: "やることを追加してください",
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
                    modelList.add(Model(
                        title: myTextController.text,
                        key: counter + 1,
                        done: false));
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
                      color: returnModelsColor(model),
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
                              caption: retutnModelsToBeStatus(model),
                              color: Colors.indigo,
                              icon: Icons.done,
                              onTap: () {
                                model.done = !model.done;
                                setState(() {});
                              },
                            ),
                          ],
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                  child: ListTile(
                                leading: const Icon(Icons.done),
                                title: Text(model.title),
                              )),
                              // Container(
                              //     width: 40,
                              //     child: InkWell(
                              //         child: Icon(
                              //           Icons.remove_circle,
                              //           color: Colors.redAccent,
                              //         ),
                              //         onTap: () {
                              //           modelList.remove(model);
                              //           setState(() {});
                              //         }))
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
  bool done;

  Model({@required this.title, @required this.key, @required this.done});
}

Color returnModelsColor(Model model) {
  if (model.done == true) {
    return Colors.grey[400];
  }
  if (model.done == false) {
    return Colors.white;
  }
}

String retutnModelsToBeStatus(Model model) {
  if (model.done == true) {
    return "未完了";
  }
  if (model.done == false) {
    return "完了";
  }
}

class DeleteAllButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      color: Theme.of(context).primaryColor,
      child: Text('全て削除'),
      onPressed: () async {
        var result = await showDialog<int>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('確認'),
              content: Text('本当に全ての「やること」を削除しますか？'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(0),
                ),
                FlatButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(1);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class DeleteDoneItmeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      color: Theme.of(context).primaryColor,
      child: Text('完了済を削除'),
      onPressed: () async {
        var result = await showDialog<int>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('確認'),
              content: Text('本当に完了済の「やること」を削除しますか？'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(0),
                ),
                FlatButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.of(context).pop(1),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
