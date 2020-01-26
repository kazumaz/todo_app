import 'package:shared_preferences/shared_preferences.dart';

class SharePrefs {
  //ここで文字列の型を作成します。あとはパーケージが保存してくれます。
  static final list_Items = "list_items";
  static final counter = "counter";
  static SharedPreferences _sharedPreferences;

  static Future setInstance() async {
    if (null != _sharedPreferences) return;
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  //setStringList()によって変更されたデータを更新し、新しいデータが方に保存されます。
  //getStringList()はinitState()(そのページに切り替わったとき)、Shared Preferenceから保存されたデータを呼び出す役割をします。

  static Future<bool> setListItems(List<String> value) =>
      _sharedPreferences.setStringList(list_Items, value);
  static List<String> getListItems() =>
      _sharedPreferences.getStringList(list_Items) ?? [];
  static void deleteListItems() => _sharedPreferences.remove(list_Items);

  static Future<bool> setCounter(int value) =>
      _sharedPreferences.setInt(counter, value);

  static int getCounter() =>
      _sharedPreferences.getInt(counter) ?? 0;
  static void deleteCounter() => _sharedPreferences.remove(counter);
}