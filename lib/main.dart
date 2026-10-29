import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

const Color _titleColor = Color(0xFF1E1B35);
const Color _mutedColor = Color(0xFF8A8A9E);
const Color _dangerColor = Color(0xFFDC2626);
const Color _dangerBackground = Color(0xFFFEE2E2);

const List<String> _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String formatTaskDate(DateTime date) {
  return "${_monthNames[date.month - 1]} ${date.day}";
}

class Task {
  String? taskTitle;
  String? taskDescription;
  String? taskSubject;
  DateTime? taskDueDate;

  Task(this.taskTitle, this.taskDescription, this.taskSubject, this.taskDueDate);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyTask',
      theme: ThemeData(
        colorScheme: .fromSeed(
            seedColor: Color(0xFF4338CA),
            primary: Color(0xFF4338CA),
            secondary: Colors.white
        )
      ),
      initialRoute: "/",
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute<Task?>(
              settings: settings,
              builder: (_) => const HomePage(title: 'Task Buddy'),
            );
          case '/form':
            return MaterialPageRoute<Task?>(
              settings: settings,
              builder: (_) => const TaskFormPage(title: 'Task Form'),
            );
        }
        return null;
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  List<Task> tasks = [];

  void onPressed() async {
    final Task? result = await Navigator.pushNamed(context, "/form");

    if (!mounted) return;
    if (result == null) return;

    setState(() {
      tasks.add(result);
    });
  }

  Future<void> onEditTask(int index) async {
    final Task original = tasks[index];

    final Task? result = await Navigator.push<Task>(
      context,
      MaterialPageRoute<Task>(
        builder: (_) => TaskFormPage(
          title: 'Task Form',
          initialTask: original,
        ),
      ),
    );

    if (!mounted || result == null) return;

    final int position = tasks.indexOf(original);
    if (position == -1) return;

    setState(() {
      tasks[position] = result;
    });
  }

  Future<void> onDeleteTask(Task task) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Delete task?',
            style: TextStyle(
              color: _titleColor,
              fontWeight: FontWeight.w700,
              fontSize: 18.0,
            ),
          ),
          content: Text(
            '"${task.taskTitle ?? ''}" will be removed from your list.',
            style: const TextStyle(
              color: _mutedColor,
              fontSize: 14.0,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: _dangerColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    setState(() {
      tasks.remove(task);
    });
  }

  void showTaskDetail(Task task) {
    showTaskDetailDialog(context, task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 150,
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.vertical(
              bottom: Radius.circular(32),
          )
        ),
        title: Padding(
          padding: EdgeInsetsGeometry.directional(
            start: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 40.0,
                ),
              ),
              Text(
                "${tasks.length} tasks to finish",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 15.0,
                ),
              )
            ],
          )
        )
      ),
      body: tasks.isEmpty
          ? Center(
              child: Text(
                "No Task Yet",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 24.0,
                ),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 96.0),
              itemCount: tasks.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.0),
              itemBuilder: (context, index) {
                final task = tasks[index];

                return TaskCard(
                  task: task,
                  onTap: () => showTaskDetail(task),
                  onEdit: () => onEditTask(index),
                  onDelete: () => onDeleteTask(task),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onPressed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.horizontal(
            left: Radius.circular(40),
            right: Radius.circular(40)
          )
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        label: Text(
          "Add Task",
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.w700,
            fontSize: 15.0,
          ),
        ),
        icon: Icon(Icons.add, color: Theme.of(context).colorScheme.secondary),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10.0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        task.taskTitle ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _titleColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 16.0,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        children: [
                          Flexible(
                            child: SubjectChip(subject: task.taskSubject ?? ''),
                          ),
                          const SizedBox(width: 10.0),
                          DueDateLabel(date: task.taskDueDate),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                _CardActionButton(
                  icon: Icons.edit_outlined,
                  iconColor: colorScheme.primary,
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.10),
                  onPressed: onEdit,
                ),
                const SizedBox(width: 8.0),
                _CardActionButton(
                  icon: Icons.delete_outline,
                  iconColor: _dangerColor,
                  backgroundColor: _dangerBackground,
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SubjectChip extends StatelessWidget {
  const SubjectChip({super.key, required this.subject});

  final String subject;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999.0),
      ),
      child: Text(
        subject.isEmpty ? 'General' : subject,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
          fontSize: 12.0,
        ),
      ),
    );
  }
}

class DueDateLabel extends StatelessWidget {
  const DueDateLabel({super.key, required this.date});

  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.calendar_today_outlined,
          size: 14.0,
          color: _mutedColor,
        ),
        const SizedBox(width: 4.0),
        Text(
          date == null ? 'No date' : formatTaskDate(date!),
          style: const TextStyle(
            color: _mutedColor,
            fontWeight: FontWeight.w500,
            fontSize: 13.0,
          ),
        ),
      ],
    );
  }
}

class _CardActionButton extends StatelessWidget {
  const _CardActionButton({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.onPressed,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(14.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 44.0,
          height: 44.0,
          child: Icon(icon, size: 20.0, color: iconColor),
        ),
      ),
    );
  }
}

Future<void> showTaskDetailDialog(BuildContext context, Task task) {
  final colorScheme = Theme.of(context).colorScheme;
  final String description = task.taskDescription ?? '';

  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0),
        contentPadding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 0),
        actionsPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 20.0),
        title: Text(
          task.taskTitle ?? '',
          style: const TextStyle(
            color: _titleColor,
            fontWeight: FontWeight.w700,
            fontSize: 18.0,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(child: SubjectChip(subject: task.taskSubject ?? '')),
                const SizedBox(width: 10.0),
                DueDateLabel(date: task.taskDueDate),
              ],
            ),
            const SizedBox(height: 16.0),
            const Divider(height: 1.0, color: Color(0xFFECECF2)),
            const SizedBox(height: 16.0),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.35,
              ),
              child: SingleChildScrollView(
                child: Text(
                  description.isEmpty ? 'No description' : description,
                  style: TextStyle(
                    color: description.isEmpty ? _mutedColor : _titleColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 14.0,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(colorScheme.primary),
                minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                ),
              ),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class TaskFormPage extends StatefulWidget {
  const TaskFormPage({super.key, required this.title, this.initialTask});

  final String title;
  final Task? initialTask;

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subjectController = TextEditingController();
  final _dueDateController = TextEditingController();

  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();

    final Task? task = widget.initialTask;
    if (task == null) return;

    _titleController.text = task.taskTitle ?? '';
    _descriptionController.text = task.taskDescription ?? '';
    _subjectController.text = task.taskSubject ?? '';
    _dueDate = task.taskDueDate;
    _dueDateController.text = _dueDate == null ? '' : formatTaskDate(_dueDate!);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subjectController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
        _dueDateController.text = formatTaskDate(picked);
      });
    }
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final task = Task(
        _titleController.text,
        _descriptionController.text,
        _subjectController.text,
        _dueDate,
      );

      Navigator.pop(context, task);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsetsGeometry.fromLTRB(10.0, 60.0, 10.0, 0),
          child: Column(
            spacing: 20,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Task Title",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16.0,
                    ),
                  ),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: "Title",
                      border: OutlineInputBorder(),
                      icon: Icon(Icons.title_outlined)
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Subject",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16.0,
                    ),
                  ),
                  TextFormField(
                    controller: _subjectController,
                    decoration: InputDecoration(
                      labelText: "Subject",
                      border: OutlineInputBorder(),
                      icon: Icon(Icons.subject_outlined)
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a subject';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Task Due Date",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16.0,
                    )
                  ),
                  TextFormField(
                    readOnly: true,
                    controller: _dueDateController,
                    onTap: () => _selectDate(context),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Date",
                        icon: Icon(Icons.calendar_today)
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a date';
                      }
                      return null;
                    },
                  ),
                ]
              ),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Description",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16.0,
                      ),
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Description",
                        icon: Icon(Icons.description_outlined)
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                  ]
              )
            ]
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
              ElevatedButton(
                  onPressed: _onSave,
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.primary),
                    minimumSize: WidgetStatePropertyAll(Size(380, 50))
                  ),
                  child: Text(
                    "Save",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w800,
                    ),
                  )
              ),
              TextButton(
                  onPressed: () => { Navigator.pop(context) },
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  )
              )
          ]
        ),
      ),
    );
  }
}
