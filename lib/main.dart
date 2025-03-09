import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Plan Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PlanManagerScreen(),
    );
  }
}

class Plan {
  String name;
  String description;
  DateTime date;
  bool isCompleted;

  Plan({
    required this.name,
    required this.description,
    required this.date,
    this.isCompleted = false,
  });
}

class PlanManagerScreen extends StatefulWidget {
  const PlanManagerScreen({super.key});

  @override
  _PlanManagerScreenState createState() => _PlanManagerScreenState();
}

class _PlanManagerScreenState extends State<PlanManagerScreen> {
  List<Plan> plans = [];
  DateTime selectedDate = DateTime.now();

  void _addPlan(Plan newPlan) {
    setState(() {
      plans.add(newPlan);
    });
  }

  void _editPlan(Plan plan) {
    TextEditingController nameController =
        TextEditingController(text: plan.name);
    TextEditingController descriptionController =
        TextEditingController(text: plan.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Plan"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Plan Name"),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  plan.name = nameController.text;
                  plan.description = descriptionController.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _removePlan(Plan plan) {
    setState(() {
      plans.remove(plan);
    });
  }

  void _markAsCompleted(Plan plan) {
    setState(() {
      plan.isCompleted = !plan.isCompleted;
    });
  }

  void _showAddPlanDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Create Plan"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Plan Name"),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty) {
                  _addPlan(Plan(
                    name: nameController.text,
                    description: descriptionController.text,
                    date: selectedDate,
                  ));
                }
                Navigator.of(context).pop();
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Plan Manager")),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: selectedDate,
            selectedDayPredicate: (day) => isSameDay(selectedDate, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                selectedDate = selectedDay;
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: plans.length,
              itemBuilder: (context, index) {
                Plan plan = plans[index];
                return Dismissible(
                  key: Key(plan.name),
                  onDismissed: (direction) {
                    _removePlan(plan);
                  },
                  background: Container(color: Colors.red),
                  child: ListTile(
                    title: Text(plan.name),
                    subtitle: Text(plan.description),
                    trailing: Icon(
                      plan.isCompleted ? Icons.check_circle : Icons.circle,
                      color: plan.isCompleted ? Colors.green : Colors.grey,
                    ),
                    onTap: () => _markAsCompleted(plan),
                    onLongPress: () => _editPlan(plan),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPlanDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
