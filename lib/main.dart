import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todo_app/shared_prefs.dart';
import 'dart:convert';

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
      // theme: ThemeData.dark(),
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
  List<String> stringTodos = [];
  final myTextController = TextEditingController();
  int counter = 0;

  @override
  void initState() {
    super.initState();
    modelList = [];
    initializeApp();
  }

  // 初期化時に、sharedpreferenceで永続化していたデータをメモリ上に読みこむ。
  void initializeApp() async {
    //インスタンスを取得
    await SharePrefs.setInstance();
    //Listにデータを取得させる
    List<String> stringTodos = SharePrefs.getListItems();
    stringTodos.forEach((String stringTodo) {
      // String -> Map -> ToDo　の順でcastし、ロードする。
      modelList.add(new Model.fromJson(json.decode(stringTodo)));
    });
    counter = SharePrefs.getCounter();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        persistentFooterButtons: <Widget>[
          // ここを解除したら設定画面
          // SelectionButton(), 
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
                          modelList.removeWhere((model) => model.done == true);
                          saveListData(modelList);
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
                          modelList.clear();
                          saveListData(modelList);
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
                      // keyboardType: TextInputType.multiline,
                      // maxLines: null,
                      controller: myTextController,
                      onSubmitted: (input) {
                        if (myTextController.text != "") {
                          modelList.add(Model(
                              title: input, key: counter + 1, done: false));
                          setState(() {});
                          counter = counter + 1;
                          saveCounter(counter);
                          saveListData(modelList);
                          myTextController.clear();
                        }
                      },
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
                    saveCounter(counter);
                    saveListData(modelList);
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
                  saveListData(modelList);
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
                                saveListData(modelList);
                              },
                            ),
                            IconSlideAction(
                              caption: "編集",
                              color: Colors.indigo,
                              icon: Icons.edit,
                              onTap: () {
                                //編集画面
                                showDialog<String>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      // String result = '';
                                      return AlertDialog(
                                        title: Text('編集してください'),
                                        content: new Row(
                                          children: <Widget>[
                                            new Expanded(
                                                child: new TextField(
                                              autofocus: true,
                                              decoration: new InputDecoration(
                                                  // labelText: "編集する場合は入力してください",
                                                  hintText: model.title),
                                              onChanged: (value) {
                                                model.title = value;
                                              },
                                            )),
                                          ],
                                        ),
                                        actions: <Widget>[
                                          FlatButton(
                                            child: Text('Cancel'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          FlatButton(
                                            child: Text('Ok'),
                                            onPressed: () {
                                              Model tmpModel = Model(
                                                  title: model.title,
                                                  key: model.key,
                                                  done: model.done);
                                              int index =
                                                  modelList.indexOf(model);
                                              modelList[index] = tmpModel;
                                              setState(() {});
                                              saveListData(modelList);
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    });
                              },
                            ),
                            // IconSlideAction(
                            //   caption: returnModelsToBeStatus(model),
                            //   color: Colors.indigo,
                            //   icon: Icons.done,
                            //   onTap: () {
                            //     model.done = !model.done;
                            //     setState(() {});
                            //     saveListData(modelList);
                            //   },
                            // ),
                          ],
                          child: Row(
                            children: <Widget>[
                              Container(
                                  width: 40,
                                  child: InkWell(
                                      child:
                                          Icon(returnModelsCheckBoxIcon(model)
                                              // color: Colors.redAccent,
                                              ),
                                      onTap: () {
                                        model.done = !model.done;
                                        setState(() {});
                                        saveListData(modelList);
                                      })),
                              Expanded(
                                  child: ListTile(
                                // leading: const Icon(Icons.done),
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

  void saveListData(List<Model> modelList) {
    stringTodos.clear();
    modelList.forEach((Model model) {
      // Todoオブジェクト -> Map -> String の順でエンコード
      var encoded = json.encode(model.toJson());
      stringTodos.add(encoded);
    });
    // 一度、sharedpreference上に永続化されているリストをクリアする。
    SharePrefs.deleteListItems();
    // 永続化
    SharePrefs.setListItems(stringTodos).then((_) {
      setState(() {});
    });
  }

  void saveCounter(int counter) {
    // 一度、sharedpreference上に永続化されているリストをクリアする。
    SharePrefs.deleteCounter();
    // 永続化
    SharePrefs.setCounter(counter);
  }
}

class Model {
  String title;
  final int key;
  bool done;

  Model({@required this.title, @required this.key, @required this.done});

  Model.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        key = json['key'],
        done = json['done'];

  Map<String, dynamic> toJson() => {
        'title': title,
        'key': key,
        'done': done,
      };
}

Color returnModelsColor(Model model) {
  if (model.done == true) {
    return Colors.grey[400];
  }
  if (model.done == false) {
    return Colors.white;
  }
}

String returnModelsToBeStatus(Model model) {
  if (model.done == true) {
    return "未完了";
  }
  if (model.done == false) {
    return "完了";
  }
}

IconData returnModelsCheckBoxIcon(Model model) {
  if (model.done == true) {
    return Icons.check_box;
  }
  if (model.done == false) {
    return Icons.check_box_outline_blank;
  }
}

// //　編集画面
// Future<String> showInputDialog(
//     BuildContext context, Model model, List<Model> modelList) {
//   return showDialog<String>(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         String result = '';
//         return AlertDialog(
//           title: Text('編集してください'),
//           content: new Row(
//             children: <Widget>[
//               new Expanded(
//                   child: new TextField(
//                 autofocus: true,
//                 decoration: new InputDecoration(
//                     // labelText: "編集する場合は入力してください",
//                     hintText: model.title),
//                 onChanged: (value) {
//                   model.title = value;
//                   print(model.title);
//                 },
//               )),
//             ],
//           ),
//           actions: <Widget>[
//             FlatButton(
//               child: Text('Ok'),
//               onPressed: () {
//                 Model tmpModel =
//                     Model(title: model.title, key: model.key, done: model.done);
//                 int index = modelList.indexOf(model);
//                 modelList[index] = tmpModel;
//                 Navigator.of(context).pop(model.title);
//                 print(model.title);
//               },
//             ),
//           ],
//         );
//       });
// }

class SelectionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => RaisedButton(
        onPressed: () {
          _navigateAndDisplaySelection(context);
        },
        child: Text('設定'),
      );

  Future<void> _navigateAndDisplaySelection(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelectionScreen()),
    );
  }
}

class SelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('選択してください'),
        ),
        body: GridView.count(
            crossAxisCount: 5, // 1行に表示する数
            crossAxisSpacing: 10.0, // 縦スペース
            mainAxisSpacing: 10.0, // 横スペース
            shrinkWrap: true,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.lens, color: Colors.blue),
                iconSize: 70.0,
                onPressed: (){},
              ),
              IconButton(
                icon: Icon(Icons.lens, color: Colors.red),
                iconSize: 70.0,
                onPressed: (){},
              ),
              IconButton(
                icon: Icon(Icons.lens, color: Colors.purple),
                iconSize: 70.0,
                onPressed: (){},
              ),
              IconButton(
                icon: Icon(Icons.lens, color: Colors.pink),
                iconSize: 70.0,
                onPressed: (){},
              ),
              IconButton(
                icon: Icon(Icons.lens, color: Colors.orange),
                iconSize: 70.0,
                onPressed: (){},
              ),
              IconButton(
                icon: Icon(Icons.lens, color: Colors.cyan),
                iconSize: 70.0,
                onPressed: (){},
              ),
              IconButton(
                icon: Icon(Icons.lens, color: Colors.black),
                iconSize: 70.0,
                onPressed: (){},
              ),
              IconButton(
                icon: Icon(Icons.lens, color: Colors.indigo),
                iconSize: 70.0,
                onPressed: (){},
              ),
              IconButton(
                icon: Icon(Icons.lens, color: Colors.brown),
                iconSize: 70.0,
                onPressed: (){},
              ),
              IconButton(
                icon: Icon(Icons.lens, color: Colors.lime),
                iconSize: 70.0,
                onPressed: (){},
              ),
            ]),

        // Center(
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: <Widget>[
        //       Padding(
        //         padding: EdgeInsets.all(8.0),
        //         child: RaisedButton(
        //           onPressed: () {
        //             Navigator.pop(context, '選択肢1');
        //           },
        //           child: Text('選択肢1'),
        //         ),
        //       ),
        //       Padding(
        //         padding: EdgeInsets.all(8.0),
        //         child: RaisedButton(
        //             onPressed: () {
        //               Navigator.pop(context, '選択肢2');
        //             },
        //             child: Text('選択肢2')),
        //       ),
        //     ],
        //   ),
        // ),
      );
}
