import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox("tasks");

  runApp(const MyApp());
}

class Task {
  final int id;
  final String title;
  final String deadline;
  final bool done;
  final String priority;

  Task({
    required this.id,
    required this.title,
    required this.deadline,
    required this.done,
    required this.priority,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "deadline": deadline,
      "done": done,
      "priority": priority,
    };
  }

  factory Task.fromMap(Map map) {
    return Task(
      id: map["id"],
      title: map["title"],
      deadline: map["deadline"],
      done: map["done"],
      priority: map["priority"],
    );
  }
}

class TaskApiService {
  static Future<List<Task>> fetchTasks() async {
    final response = await http.get(
      Uri.parse("https://dummyjson.com/todos"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List todos = data["todos"];

      final random = Random();
      final priorities = ["niski", "średni", "wysoki"];

      return todos.map((todo) {
        return Task(
          id: todo["id"],
          title: todo["todo"],
          deadline: "brak",
          done: todo["completed"],
          priority: priorities[random.nextInt(priorities.length)],
        );
      }).toList();
    } else {
      throw Exception("Błąd pobierania danych z API");
    }
  }
}

class TaskLocalDatabase {
  static Box get _box => Hive.box("tasks");

  static List<Task> getTasks() {
    return _box.values.map((item) {
      return Task.fromMap(Map<String, dynamic>.from(item));
    }).toList();
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    await _box.clear();

    for (final task in tasks) {
      await _box.put(task.id, task.toMap());
    }
  }

  static Future<void> addTask(Task task) async {
    await _box.put(task.id, task.toMap());
  }

  static Future<void> updateTask(Task task) async {
    await _box.put(task.id, task.toMap());
  }

  static Future<void> deleteTask(int id) async {
    await _box.delete(id);
  }

  static Future<void> deleteAllTasks() async {
    await _box.clear();
  }

  static bool isEmpty() {
    return _box.isEmpty;
  }
}

class TaskSyncService {
  static Future<void> loadInitialDataIfNeeded() async {
    if (!TaskLocalDatabase.isEmpty()) {
      return;
    }

    final tasks = await TaskApiService.fetchTasks();
    await TaskLocalDatabase.saveTasks(tasks);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Task>> tasksFuture;

  int allTasksCount = 0;
  int doneTasksCount = 0;
  int todoTasksCount = 0;

  @override
  void initState() {
    super.initState();
    tasksFuture = loadTasks();
  }

  Future<List<Task>> loadTasks() async {
    await TaskSyncService.loadInitialDataIfNeeded();
    final tasks = TaskLocalDatabase.getTasks();

    allTasksCount = tasks.length;
    doneTasksCount = tasks.where((task) => task.done).length;
    todoTasksCount = tasks.where((task) => !task.done).length;

    return tasks;
  }

  void refreshTasks() {
    setState(() {
      tasksFuture = loadTasks();
    });
  }

  Future<void> addTask() async {
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch,
      title: "Nowe zadanie",
      deadline: "brak",
      done: false,
      priority: "średni",
    );

    await TaskLocalDatabase.addTask(task);
    refreshTasks();
  }

  Future<void> deleteAllTasks() async {
    await TaskLocalDatabase.deleteAllTasks();
    refreshTasks();
  }

  Future<void> changeTaskStatus(Task task, bool value) async {
    final updatedTask = Task(
      id: task.id,
      title: task.title,
      deadline: task.deadline,
      done: value,
      priority: task.priority,
    );

    await TaskLocalDatabase.updateTask(updatedTask);
    refreshTasks();
  }

  Future<void> deleteTask(Task task) async {
    await TaskLocalDatabase.deleteTask(task.id);
    refreshTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("KrakFlow Hive"),
        actions: [
          IconButton(
            onPressed: deleteAllTasks,
            icon: const Icon(Icons.delete_forever),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addTask,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Wszystkie: $allTasksCount"),
                Text("Wykonane: $doneTasksCount"),
                Text("Do zrobienia: $todoTasksCount"),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Task>>(
              future: tasksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text("Błąd: ${snapshot.error}"),
                  );
                }

                final tasks = snapshot.data ?? [];

                if (tasks.isEmpty) {
                  return const Center(
                    child: Text("Brak zadań"),
                  );
                }

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];

                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: Checkbox(
                          value: task.done,
                          onChanged: (value) {
                            changeTaskStatus(task, value ?? false);
                          },
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.done
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        subtitle: Text(
                          "termin: ${task.deadline} | priorytet: ${task.priority}",
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            deleteTask(task);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}