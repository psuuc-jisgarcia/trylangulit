import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  await Hive.openBox('items');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hive Todo List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late Box _itemsBox;
  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _itemsBox = Hive.box('items');
  }

  void _addItem(String itemName) {
    _itemsBox.add({'name': itemName, 'isChecked': false});
    setState(() {});
  }

  void _toggleItem(int index) {
    _itemsBox.putAt(
        index,
        {'name': _itemsBox.getAt(index)['name'], 'isChecked': !_itemsBox.getAt(index)['isChecked']});
    setState(() {});
  }

  void _clearSelectedItems() {
    for (int i = _itemsBox.length - 1; i >= 0; i--) {
      if (_itemsBox.getAt(i)!['isChecked']) {
        _itemsBox.deleteAt(i);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _clearSelectedItems,
          ),
        ],
      ),
      body: Column(
        children: [
          TextField(
            controller: _textEditingController,
            decoration: InputDecoration(
              labelText: 'Add item',
            ),
            onSubmitted: (value) {
              _addItem(value);
              _textEditingController.clear();
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _itemsBox.length,
              itemBuilder: (context, index) {
                final item = _itemsBox.getAt(index) as Map?;
                return ListTile(
                  leading: Checkbox(
                    value: item!['isChecked'] as bool,
                    onChanged: (isChecked) {
                      _toggleItem(index);
                    },
                  ),
                  title: Text(item['name'] as String),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
