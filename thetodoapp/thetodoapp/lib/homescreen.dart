import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'classtask.dart';

void main() {
  runApp(
    const MaterialApp(
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Task> tasks = [];
  List<Task> filteredTasks = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    filteredTasks = tasks;
    // Add listener to the tasks collection in Firebase
    FirebaseFirestore.instance.collection('tasks').snapshots().listen(
      (snapshot) {
        List<Task> updatedTasks = [];
        for (var doc in snapshot.docs) {
          String title = doc.data()['title'] ?? '';
          String description = doc.data()['description'] ?? '';
          // ignore: unnecessary_null_comparison
          if (title != null && description != null) {
            updatedTasks.insert(
              0,
              Task(title, description),
            );
          }
        }
        setState(
          () {
            tasks = updatedTasks;
            filterTasks(searchQuery);
          },
        );
      },
    );
  }

  Future<void> addTaskToFirebase(Task task) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.settings = const Settings(persistenceEnabled: true);
    CollectionReference tasks = firestore.collection('tasks');
    await tasks.add(
      {
        'title': task.title,
        'description': task.description,
      },
    );
  }

  void deleteTask(Task task) async {
    CollectionReference tasks = FirebaseFirestore.instance.collection('tasks');
    QuerySnapshot querySnapshot = await tasks
        .where('title', isEqualTo: task.title)
        .where('description', isEqualTo: task.description)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      querySnapshot.docs.first.reference.delete();
    }
  }

  int currentIndex = 0;

  void onItemTapped(int index) {
    setState(
      () {
        currentIndex = index;
      },
    );

    if (currentIndex == 0) {
      return alertdialogbox();
    } else if (currentIndex == 1) {
      return showAboutApp();
    }
  }

  void showAboutApp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('The Agenda App'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'This app was created by Asare Benedict Nana',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 10),
              Text('Version: 1.0.0'),
              SizedBox(height: 10),
              Text(
                  '''Description: \nThis is a simple to-do list app called "Agenda Everyday". The app allows users to add and remove tasks, mark them as completed, and filter them based on a search query. The app has two screens: the main screen, which displays the list of tasks, and the add task screen, which allows users to add a new task. '''),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(fontSize: 20),
                selectionColor: Colors.black,
              ),
            ),
          ],
        );
      },
    );
  }

  void alertdialogbox() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String title = "";
        String description = "";
        return AlertDialog(
          backgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Add Agenda',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    label: Text(
                      'Title',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  onChanged: (value) {
                    title = value;
                  },
                ),
                TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    label: Text(
                      'Description',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  onChanged: (value) {
                    description = value;
                  },
                ),
                Column(
                  children: <Widget>[
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (title.isEmpty || description.isEmpty) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Empty fields'),
                                  content: const Text(
                                      'Please fill out both fields before adding a task.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            setState(
                              () {
                                addTaskToFirebase(
                                    Task(title, description, completed: false));
                                tasks.insert(0,
                                    Task(title, description, completed: false));
                              },
                            );
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('ADD TO LIST'),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void filterTasks(String query) {
    setState(
      () {
        searchQuery = query;
        if (query.isEmpty) {
          filteredTasks = tasks;
        } else {
          filteredTasks = tasks
              .where(
                (task) =>
                    task.title.toLowerCase().contains(
                          query.toLowerCase(),
                        ) ||
                    task.description.toLowerCase().contains(
                          query.toLowerCase(),
                        ),
              )
              .toList();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text(
          'Agenda Everyday',
          style: TextStyle(fontSize: 35),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 136, 34, 27),
        toolbarHeight: 60,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_task_rounded,
              color: Colors.black,
            ),
            label: 'Add task',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.question_mark_outlined,
              color: Colors.black,
            ),
            label: 'About app',
          )
        ],
        backgroundColor: const Color.fromARGB(255, 136, 34, 27),
        currentIndex: currentIndex,
        onTap: (value) => onItemTapped(value),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: InkWell(
          onTap: () {
            FocusScope.of(context).unfocus();
            searchQuery = "";
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              searchBox(),
              tasks.isEmpty
                  ? const Center(
                      child: Text(
                        'No tasks added yet.\nTap the + button to add a new task.',
                        style: TextStyle(
                            fontSize: 15, fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Expanded(
                      child: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          searchQuery;
                        },
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('tasks')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return ListView.builder(
                                itemCount: filteredTasks.length,
                                itemBuilder: (context, index) {
                                  final task = filteredTasks[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 0),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 5),
                                      child: ListTile(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 5),
                                        tileColor: Colors.white,
                                        title: Text(
                                          task.title,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          task.description,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        trailing: InkWell(
                                          onTap: () {
                                            setState(() {
                                              deleteTask(task);
                                              tasks.removeAt(index);
                                            });
                                          },
                                          child: Container(
                                            height: 35,
                                            width: 35,
                                            decoration: BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.delete_forever,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        leading: Checkbox(
                                          value: task.completed,
                                          onChanged: (value) {
                                            setState(
                                              () {
                                                task.completed = true;
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                            if (snapshot.hasError) {
                              return const Text('Something went wrong');
                            }
                            return Container();
                          },
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget searchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextFormField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.black,
                    size: 25,
                  ),
                  border: InputBorder.none,
                  hintText: 'Search a task...',
                  hintStyle: TextStyle(fontSize: 20),
                ),
                onChanged: (value) {
                  filterTasks(value);
                },
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(
                height: 5,
              ),
              Text(
                "The Day's Agenda",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
