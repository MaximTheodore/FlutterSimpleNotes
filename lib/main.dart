
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_listview_note/provider/NoteItemProvider.dart';

void main() {
  runApp(
    ChangeNotifierProvider<NoteItemProvider>(
      create: (context) => NoteItemProvider(),
      lazy: false,
      child: const MainApp(),
    )
  );
}


class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return 
    MaterialApp(
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/modify':
            final args = settings.arguments as int;
            return MaterialPageRoute(
              builder: (_) => ModifyPage(index: args),
            );
          case '/home':
          default:
            return MaterialPageRoute(builder: (_) => ListNotes());
        }
      },
      initialRoute: '/home',

    );
  }
}


class ListNotes extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _ListNotesScreenState();

}
class _ListNotesScreenState extends State<ListNotes>{
  int selectedIndex = -1;
  @override
  Widget build(BuildContext context) {
    var noteList = context.watch<NoteItemProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Stack(
        children: [
          ReorderableListView.builder
          (
            padding: const EdgeInsets.only(
              top: 60,
              left: 0,
              right: 0,
              bottom: 0
            ),
            
            itemCount: noteList.getNoteItems().length,
            itemBuilder: (BuildContext contex, int index) =>
              ListTile(
                key: ValueKey(index),
                title: Text(
                  noteList.getNoteItems()[index].name,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18
                    ),
                ),
                onTap: () => 
                  setState(() {
                    selectedIndex = index;
                  }),
                selected: index == selectedIndex,
                selectedTileColor: const Color.fromARGB(255, 145, 144, 144),
                selectedColor: Colors.white,
                
              ), 
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    if (oldIndex < newIndex){
                      newIndex -= 1; 
                    }
                    final note = noteList.getNoteItems().removeAt(oldIndex);
                    noteList.getNoteItems().insert(newIndex, note);
                  });
                }
             
          ),
          Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              border: Border.all(color: Colors.black, width: 2),
              color: Colors.white
            ),
            child: Row(
              children: [
                Text(""),
                SizedBox(width: 50,),
                ElevatedButton(
                  onPressed: (){
                    setState(() {
                      noteList.removeNoteItem(selectedIndex);
                      selectedIndex = -1;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder()
                  ), 
                  child: Icon(
                    Icons.delete_forever_outlined, 
                    size: 32,
                    color: Colors.black,
                  ),
                ),
                ElevatedButton(
                  onPressed: (){
                    Navigator.pushNamed(context, '/modify', arguments: selectedIndex);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder()
                  ), 
                  child: Icon(
                    Icons.upgrade, 
                    size: 32,
                    color: Colors.black,
                    ),
                )
              ],
            ),
          ),
        Positioned(
          bottom: 10,
          right: 10,
          child: 
            ElevatedButton(
              onPressed: (){
                setState(() {
                  selectedIndex = -1;
                });
                Navigator.pushNamed(context, '/modify', arguments: selectedIndex);
              },
              style: ElevatedButton.styleFrom(
                shape: CircleBorder()
              ), 
              child: Icon(
                Icons.add, 
                size: 40,
                color: Colors.black,
                ),
            )
        )
        ]
      ),
    );
  }

}

class ModifyPage extends StatefulWidget{
  final int index;

  ModifyPage({Key? key, this.index = -1}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _ModifyPageState();

}
class _ModifyPageState extends State<ModifyPage>{
  late TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    var noteList = context.read<NoteItemProvider>();
    _controller = TextEditingController(
      text: widget.index == -1 ? '' : noteList.getNoteItem(widget.index).name
    );
  }
  @override
  Widget build(BuildContext context) {
    var noteList = context.watch<NoteItemProvider>();
    return Scaffold( 
      appBar: AppBar(
        title: Text(widget.index == -1 ? 'Add' : 'Edit'),
      ),
      body: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.all(50),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              
              controller: _controller,
              decoration: InputDecoration(
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                contentPadding: EdgeInsets.only(
                  top: 10,
                  left: 10,
                  right: 10
                  ),
                hintText: "Введите заметку"
              ),
            ),
            ElevatedButton(
              onPressed: (){
                setState(() {
                  if (widget.index == -1 && _controller.text.isNotEmpty) {
                    noteList.addNoteItem(_controller.text);
                  } else {
                    noteList.getNoteItem(widget.index).name = _controller.text;
                  }
                });
                Navigator.pushNamed(context, '/home');
              }, 
              child: Text(widget.index == -1 ? 'Добавить' : 'Изменить')),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: (){
                  Navigator.pushNamed(context, '/home');
                }, 
                child: Text("Назад"))
          ],

          
        ),
      ),
    );
  }

}
