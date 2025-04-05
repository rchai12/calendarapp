import 'package:flutter/material.dart';
import 'calendar_page.dart';
import 'ongoing_page.dart';
import 'pending_page.dart';
import 'completed_page.dart';
import 'task.dart';
//import 'priority.dart';
import 'status.dart';
import 'task_actions.dart';
//import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: TaskScreen(),
    );
  }
}

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  final List<Task> _tasks = [];
  late Map<DateTime, List<Task>> _tasksByDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_tabChanged);
    _tasksByDate = {};
    TaskActions.loadTasksFromFirestore().then((loadedTasks) {
      setState(() {
        _tasks.addAll(loadedTasks);
        _buildTaskMap();
      });
    });
  }

  void _onDateSelected(DateTime newDate) {
    setState(() {
      _selectedDate = DateTime(newDate.year, newDate.month, newDate.day);
    });
  }

  void _buildTaskMap() {
    _tasksByDate = {};
    for (var task in _tasks.where((t) => t.status != TaskStatus.completed)) {
      final dateOnly = DateTime(task.date.year, task.date.month, task.date.day);
      _tasksByDate.update(dateOnly, (list) => list..add(task), ifAbsent: () => [task]);
    }
  }

  void _tabChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_tabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _addTask() {
    TaskStatus defaultStatus;
    if (_tabController.index == 0 || _tabController.index == 1) {
      defaultStatus = TaskStatus.ongoing; 
    } else if (_tabController.index == 2) {
      defaultStatus = TaskStatus.pending;
    } else {
      defaultStatus = TaskStatus.completed;
    }
    TaskActions.showAddTaskDialog(context, (newTask) {
      setState(() {
        _tasks.add(newTask);
        _buildTaskMap();
      });
    }, _selectedDate, defaultStatus);
  }

  void _editTask(Task task) {
    TaskActions.showEditTaskDialog(context, task, (updatedTask) {
      setState(() {
        TaskActions.updateTask(task, updatedTask, _tasks);
        _buildTaskMap();
      });
    });
  }

  void _toggleTaskStatus(Task task) {
    setState(() {
      TaskActions.toggleStatus(task); 
      _buildTaskMap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plan Manager'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Calendar'),
            Tab(text: 'Ongoing'),
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CalendarPage(
            selectedDate: _selectedDate,
            onDateSelected: _onDateSelected,
            tasks: _tasks,
            tasksByDate: _tasksByDate,
            onEditTask: _editTask,
            onToggleStatus: _toggleTaskStatus,
          ),
          OngoingPage(
            tasks: _tasks,
            onEditTask: _editTask,
            onToggleStatus: _toggleTaskStatus,
          ),
          PendingPage(
            tasks: _tasks, 
            onEditTask: _editTask,
            onToggleStatus: _toggleTaskStatus,
          ),
          CompletedPage(
            tasks: _tasks, 
            onEditTask: _editTask,
            onToggleStatus: _toggleTaskStatus,
          ),
        ],
      ),
      floatingActionButton:FloatingActionButton(
          onPressed: () {
            _addTask();
          },
          child: Icon(Icons.add),
          tooltip: 'Add Task',
        ),
    );
  }
}