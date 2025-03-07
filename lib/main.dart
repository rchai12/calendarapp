import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

void main() => runApp(TaskManagerApp());

enum PriorityLabel {
  low('Low', Colors.blue),
  medium('Medium', Colors.orange),
  high('High', Colors.pink);

  const PriorityLabel(this.label, this.color);
  final String label;
  final Color color;

  static final List<DropdownMenuEntry<PriorityLabel>> entries = UnmodifiableListView<DropdownMenuEntry<PriorityLabel>>(
    values.map<DropdownMenuEntry<PriorityLabel>>(
      (PriorityLabel priority) => DropdownMenuEntry<PriorityLabel>(
        value: priority,
        label: priority.label,
        enabled: priority.label != 'Grey',
        style: MenuItemButton.styleFrom(foregroundColor: priority.color),
      ),
    ),
  );
}

class Task {
  String _title;
  String _description;
  bool _status;
  PriorityLabel _priority = PriorityLabel.low;
  DateTime _date;

  Task({required String title, required String description, bool status = false, required PriorityLabel priority, required DateTime date,})  
      : _title = title,
        _description = description,
        _status = status,
        _priority = priority,
        _date = date;

  String get title => _title;
  String get description => _description;
  bool get status => _status;
  PriorityLabel get priority => _priority;
  DateTime get date => _date; 

  void setTitle(String title) => _title = title;
  void setDescription(String description) => _description = description;
  void toggleStatus() => _status = !_status;
  void setPriority(PriorityLabel priority) => _priority = priority;
  void setDate(DateTime date) => _date = date;
}



class TaskManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  final List<Task> _tasks = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  PriorityLabel _selectedPriority = PriorityLabel.low;
  DateTime _date = DateTime.now();
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);


    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(), 
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked; 
      });
    }
  }

  void _addTask() {
    if (_titleController.text.isNotEmpty && _descriptionController.text.isNotEmpty) {
      setState(() {
        _tasks.add(Task(title: _titleController.text, description: _descriptionController.text, priority: _selectedPriority, date: _date));
        _sortTasksByPriority();
        _titleController.clear();
        _descriptionController.clear();
        _selectedPriority = PriorityLabel.low;
        _date = DateTime.now();
      });
      Navigator.of(context).pop();
    }
  }

  void _sortTasksByPriority() {
    setState(() {
      _tasks.sort((task1, task2) => task2.priority.index.compareTo(task1.priority.index));
    });
  }

  void _editTask(int index) {
    _titleController.text = _tasks[index].title;
    _descriptionController.text = _tasks[index].description;
    _selectedPriority = _tasks[index].priority;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 50,
          ),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Task Title'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Task Description'),
                ),
                 Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0), 
                  child: DropdownButtonFormField<PriorityLabel>(
                    value: _selectedPriority,
                    items: PriorityLabel.values.map((PriorityLabel priority) {
                      return DropdownMenuItem<PriorityLabel>(
                        value: priority,
                        child: Text(priority.label, style: TextStyle(color: priority.color)),
                      );
                    }).toList(),
                    onChanged: (PriorityLabel? newValue) {
                      setState(() {
                        _selectedPriority = newValue!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Select Date: ${DateFormat('MM-dd-yyyy').format(_date)}'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _tasks[index].setTitle(_titleController.text);
                      _tasks[index].setDescription(_descriptionController.text);
                      _tasks[index].setPriority(_selectedPriority);
                      _sortTasksByPriority();
                    });
                    _titleController.clear();
                    _descriptionController.clear();
                    Navigator.of(context).pop();
                  },
                  child: Text('Save Changes'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleTaskStatus(int index) {
    setState(() {
      _tasks[index].toggleStatus();
      _sortTasksByPriority();
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
      _sortTasksByPriority();
    });
  }

  void _showAddTaskMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 50, 
          ),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Task Title'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Task Description'),
                ),
                 Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0), 
                  child: DropdownButtonFormField<PriorityLabel>(
                    value: _selectedPriority,
                    items: PriorityLabel.values.map((PriorityLabel priority) {
                      return DropdownMenuItem<PriorityLabel>(
                        value: priority,
                        child: Text(priority.label, style: TextStyle(color: priority.color)),
                      );
                    }).toList(),
                    onChanged: (PriorityLabel? newValue) {
                      setState(() {
                        _selectedPriority = newValue!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Select Date: ${DateFormat('MM-dd-yyyy').format(_date)}'), 
                ),
                ElevatedButton(onPressed: _addTask, child: Text('Add Task')),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ongoingTasks = _tasks.where((task) => !task.status).toList();
    final completedTasks = _tasks.where((task) => task.status).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Ongoing'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView.builder(
            itemCount: ongoingTasks.length,
            itemBuilder: (context, index) {
              final task = ongoingTasks[index];
              return ListTile(
                onTap: () => _editTask(_tasks.indexOf(task)),
                leading: IconButton(
                  icon: Icon(task.status ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                  onPressed: () => _toggleTaskStatus(_tasks.indexOf(task)),
                ),
                title: Text(task.title),
                subtitle: Text('Priority: ${task.priority.label}\t\t Due: ${DateFormat('MM-dd-yyyy').format(task.date)}', style: TextStyle(color: task.priority.color)),
              );
            },
          ),
          ListView.builder(
            itemCount: completedTasks.length,
            itemBuilder: (context, index) {
              final task = completedTasks[index];
              return ListTile(
                onTap: () => _editTask(_tasks.indexOf(task)),
                leading: IconButton(
                  icon: Icon(Icons.check_circle),
                  onPressed: () => _toggleTaskStatus(_tasks.indexOf(task)),
                ),
                title: Text(task.title, style: TextStyle(decoration: TextDecoration.lineThrough)),
                subtitle: Text('Priority: ${task.priority.label}\t\t Due: ${DateFormat('MM-dd-yyyy').format(task.date)}', style: TextStyle(color: task.priority.color)),
              );
            },
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _showAddTaskMenu,
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}