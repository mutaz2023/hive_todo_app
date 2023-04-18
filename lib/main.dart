//import 'package:flutter/gestures.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_todo_app/empty_list.dart';
import 'package:hive_todo_app/task.dart';

void main() async {
  //await Hive.initFlutter();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());

  await Hive.openBox<Task>("tasksBox");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Box<Task>? tasksBox;
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    tasksBox = Hive.box("tasksBox");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("TODO"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.work), child: Text('TODO')),
              Tab(
                  icon: Icon(Icons.format_underline),
                  child: Text('InProgress')),
              Tab(icon: Icon(Icons.done), child: Text('Done')),
            ],
          ),
        ),
        body: ValueListenableBuilder(
          valueListenable: tasksBox!.listenable(),
          builder: (context, value, child) {
            List<Task> myList = [];

            for (int i = 0; i < tasksBox!.length; i++) {
              Task obj = Task(
                  tasksBox!.getAt(i)!.title, tasksBox!.getAt(i)!.completed);
              myList.add(obj);
            }

            List<Task> myListTODO =
                myList.where((element) => element.completed == "todo").toList();
            List<Task> myListInProgrss = myList
                .where((element) => element.completed == "inProgress")
                .toList();
            List<Task> myListCompleted =
                myList.where((element) => element.completed == "done").toList();
            print("called");

            return TabBarView(
              physics: const BouncingScrollPhysics(),
              dragStartBehavior: DragStartBehavior.down,
              children: [
                tabBarSingleView(myListTODO, "todo"),
                tabBarSingleView(myListInProgrss, "inProgress"),
                tabBarSingleView(myListCompleted, "done"),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xff0D3257),
          child: const Icon(Icons.add),
          onPressed: () => showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Add New Task'),
                  content: TextField(
                      controller: textEditingController,
                      decoration: const InputDecoration(hintText: "Enter task"),
                      autofocus: true),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('SAVE'),
                      onPressed: () => onAddTask(),
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }

  Widget tabBarSingleView(List<Task> list, String type) {
    if (list.isEmpty) {
      return const EmptyList();
    } else {
      return ListView.separated(
        separatorBuilder: (context, index) => const Divider(),
        itemCount: list.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Row(
              children: [
                Text(list[index].title),
                Expanded(child: Container()),
                Container(
                  decoration: BoxDecoration(
                      color: list[index].completed == "done"
                          ? Colors.green
                          : list[index].completed == "inProgress"
                              ? Colors.orange
                              : Colors.red,
                      borderRadius: BorderRadius.circular(5)),
                  width: 10,
                  height: 10,
                )
              ],
            ),
            trailing: type == "todo"
                ? IconButton(
                    icon: const Icon(Icons.arrow_right),
                    onPressed: () async =>
                        markAsInProgress(index, tasksBox!.getAt(index)!.title),
                  )
                : type == "inProgress"
                    ? Container(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_left),
                              onPressed: () async => markAsTODO(
                                  index, tasksBox!.getAt(index)!.title),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_right),
                              onPressed: () async => markAsCompleted(
                                  index, tasksBox!.getAt(index)!.title),
                            )
                          ],
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.delete_outlined),
                        onPressed: () async => onDeleteTask(index),
                      ),
          );
        },
      );
    }
  }

  void onAddTask() async {
    if (textEditingController.text.isNotEmpty) {
      final newTask = Task(textEditingController.text, "todo");
      await tasksBox!.add(newTask);
      Navigator.pop(context);
      textEditingController.clear();

      return;
    }
  }

  Future<void> onDeleteTask(int index) async {
    await tasksBox!.deleteAt(index);
  }

  Future<void> markAsTODO(int index, String title) async {
    tasksBox!.putAt(index, Task(title, "todo"));
  }

  Future<void> markAsInProgress(int index, String title) async {
    tasksBox!.putAt(index, Task(title, "inProgress"));
  }

  Future<void> markAsCompleted(int index, String title) async {
    await tasksBox!.putAt(index, Task(title, "done"));
  }
}
