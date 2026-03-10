import 'package:flutter/material.dart';
import 'package:sejjjjj/Weather/services/reminder_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderScreen extends StatefulWidget {
  @override
  _ReminderScreenState createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final ReminderService _reminderService = ReminderService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Plant Reminders")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _reminderService.getUserReminders(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var reminders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              var reminder = reminders[index];
              var data = reminder.data() as Map<String, dynamic>?;

              String title = data?['title'] ?? "No Title";
              String repeatType = data?['repeatType'] ?? "One-time";
              DateTime dateTime = (data?['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now();

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text(title),
                  subtitle: Text("Reminder at: ${dateTime.toString()} ($repeatType)"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _reminderService.deleteReminder(reminder.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReminderDialog(),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddReminderDialog() async {
    TextEditingController titleController = TextEditingController();
    DateTime? selectedDateTime;
    String repeatType = "One-time"; // Default

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Add Reminder"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: "Reminder Title"),
                  ),
                  DropdownButton<String>(
                    value: repeatType,
                    onChanged: (String? newValue) {
                      setState(() {
                        repeatType = newValue!;
                      });
                    },
                    items: ["One-time", "Daily", "Weekly", "Monthly"]
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );

                        if (pickedTime != null) {
                          setState(() {
                            selectedDateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      }
                    },
                    child: Text("Select Date & Time"),
                  ),
                  if (selectedDateTime != null)
                    Text("Selected: ${selectedDateTime.toString()}"),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    if (titleController.text.isNotEmpty && selectedDateTime != null) {
                      await _reminderService.addReminder(
                        titleController.text,
                        selectedDateTime!,
                        repeatType,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
