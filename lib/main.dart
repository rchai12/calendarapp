import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

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
        _date = DateTime(date.year, date.month, date.day);

  String get title => _title;
  String get description => _description;
  bool get status => _status;
  PriorityLabel get priority => _priority;
  DateTime get date => _date; 

  void setTitle(String title) => _title = title;
  void setDescription(String description) => _description = description;
  void toggleStatus() => _status = !_status;
  void setPriority(PriorityLabel priority) => _priority = priority;
  void setDate(DateTime date) => _date = DateTime(date.year, date.month, date.day);
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
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  PriorityLabel _selectedPriority = PriorityLabel.low;
  DateTime _date = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  late TabController _tabController;
  late Map<DateTime, List<Task>> _tasksByDate = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tasksByDate = {}; 

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
      initialDate: _date = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = DateTime(picked.year, picked.month, picked.day); 
      });
    }
  }

  void _addTask() {
    if (_titleController.text.isNotEmpty && _descriptionController.text.isNotEmpty) {
      setState(() {
        final newTask = Task(
          title: _titleController.text,
          description: _descriptionController.text,
          priority: _selectedPriority,
          date: DateTime(_date.year, _date.month, _date.day),
        );
        print('Adding task to list');
        print(_date);
        if (!_tasksByDate.containsKey(_date)) {
          _tasksByDate[_date] = [];
        }
        _tasksByDate[_date]?.add(newTask);
        _sortTasksByPriority(_date);
        _titleController.clear();
        _descriptionController.clear();
        _selectedPriority = PriorityLabel.low;
      });
      Navigator.of(context).pop();
    }
  }

  void _sortTasksByPriority(DateTime date) {
    setState(() {
      _tasksByDate[date]?.sort((task1, task2) => task2.priority.index.compareTo(task1.priority.index));
    });
  }

  void _editTask(Task task) {
    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _selectedPriority = task.priority;
    _date = task.date;

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
                      if (_tasksByDate.containsKey(_date)) {
                        final index = _tasksByDate[_date]?.indexOf(task);
                        if (index != null && index != -1) {
                          _tasksByDate[_date]?[index] = Task(
                            title: _titleController.text,
                            description: _descriptionController.text,
                            priority: _selectedPriority,
                            date: _date,
                            status: task.status,
                          );
                        }
                      }
                      _sortTasksByPriority(_date);
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


  void _toggleTaskStatus(DateTime taskDate, int taskIndex) {
    setState(() {
      final taskList = _tasksByDate[taskDate];
      if (taskList != null && taskIndex >= 0 && taskIndex < taskList.length) {
        taskList[taskIndex].toggleStatus();
        _sortTasksByPriority(taskDate);
      }
    });
  }

  void _deleteTask(DateTime taskDate, int taskIndex) {
    setState(() {
      final taskList = _tasksByDate[taskDate];
      if (taskList != null && taskIndex >= 0 && taskIndex < taskList.length) {
        taskList.removeAt(taskIndex);
        if (taskList.isEmpty) {
          _tasksByDate.remove(taskDate);
        }
      }
      _sortTasksByPriority(taskDate);
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

  List<Task> _getTasksByStatus(bool isCompleted) {
    return _tasksByDate[_date]?.where((task) => task.status == isCompleted).toList() ?? [];
  }

  void _resetToToday() {
    setState(() {
      _date = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    });
  }

  List<Task> _getAllTasksByStatus(bool isCompleted) {
    List<Task> allTasks = [];
    _tasksByDate.forEach((date, tasks) {
      allTasks.addAll(tasks.where((task) => task.status == isCompleted));
    });
    return allTasks;
  }

  @override
  Widget build(BuildContext context) {
    var ongoingTasks = _getTasksByStatus(false);
    final completedTasks = _getAllTasksByStatus(true);
    final allOngoingTasks = _getAllTasksByStatus(false); 

    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
        actions: [
          IconButton(
            icon: Icon(Icons.today),
            onPressed: _resetToToday,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Calendar'),
            Tab(text: 'Ongoing'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Column(
            children: [
              TableCalendar(
                firstDay: DateTime(1900, 1, 1),
                lastDay: DateTime(2101),
                focusedDay: _date,
                selectedDayPredicate: (day) => isSameDay(day, _date),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _date = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);;
                  });
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    final localDate = DateTime(date.year, date.month, date.day);
                    ongoingTasks = _tasksByDate[localDate]?.where((task) => !task.status).toList() ?? [];
                    if (ongoingTasks?.isNotEmpty ?? false) {
                      return Positioned(
                        bottom: 1,
                        child: CircleAvatar(
                          radius: 5,
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: ongoingTasks.length,
                  itemBuilder: (context, index) {
                    final task = ongoingTasks[index];
                    return ListTile(
                      onTap: () => _editTask(task),
                      leading: IconButton(
                        icon: Icon(task.status ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                        onPressed: () => _toggleTaskStatus(_date, index),
                      ),
                      title: Text(task.title),
                      subtitle: Text(
                        'Priority: ${task.priority.label}\t\t Due: ${DateFormat('MM-dd-yyyy').format(task.date)}', style: TextStyle(color: task.priority.color),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          ListView.builder(
            itemCount: allOngoingTasks.length,
            itemBuilder: (context, index) {
              final task = allOngoingTasks[index];
              return ListTile(
                onTap: () => _editTask(task),
                leading: IconButton(
                  icon: Icon(task.status ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                  onPressed: () => _toggleTaskStatus(task.date, _tasksByDate[task.date]?.indexOf(task) ?? -1),
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
                onTap: () => _editTask(task),
                leading: IconButton(
                  icon: Icon(Icons.check_circle),
                  onPressed: () => _toggleTaskStatus(task.date, _tasksByDate[task.date]?.indexOf(task) ?? -1),
                ),
                title: Text(task.title, style: TextStyle(decoration: TextDecoration.lineThrough)),
                subtitle: Text('Priority: ${task.priority.label}\t\t Due: ${DateFormat('MM-dd-yyyy').format(task.date)}', style: TextStyle(color: task.priority.color)),
              );
            },
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 1 || _tabController.index == 0 ? FloatingActionButton(
        onPressed: _showAddTaskMenu,
        child: Icon(Icons.add),
      )
      : null,
    );
  }
}