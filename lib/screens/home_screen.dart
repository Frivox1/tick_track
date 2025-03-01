import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/task_card.dart';
import '../models/task.dart';
import '../screens/task_detail_screen.dart';
import '../providers/app_state_provider.dart';
import '../models/label.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 100,
            forceMaterialTransparency: true,
            title: Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Kanban Board',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                ),
              ),
            ),
          ),
          backgroundColor: Colors.grey[100],
          body: LayoutBuilder(
            builder: (context, constraints) {
              final columnWidth =
                  constraints.maxWidth / 3 > 200
                      ? constraints.maxWidth / 3
                      : 200.0;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: columnWidth * 3,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildColumn('To Do', context, appState, columnWidth),
                      _buildColumn(
                        'In Progress',
                        context,
                        appState,
                        columnWidth,
                      ),
                      _buildColumn('Done', context, appState, columnWidth),
                    ],
                  ),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addTask(context, appState),
            backgroundColor: Colors.black,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildColumn(
    String status,
    BuildContext context,
    AppStateProvider appState,
    double width,
  ) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 40.0, bottom: 8.0),
            child: Text(
              status,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: DragTarget<Task>(
              builder: (context, candidateData, rejectedData) {
                final tasks =
                    appState.tasks
                        .where((task) => task.status == status)
                        .toList();
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return _buildDraggableTaskCard(
                      tasks[index],
                      context,
                      appState,
                    );
                  },
                );
              },
              onAccept: (Task task) {
                task.status = status;
                appState.updateTask(task);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableTaskCard(
    Task task,
    BuildContext context,
    AppStateProvider appState,
  ) {
    return Draggable<Task>(
      data: task,
      child: TaskCard(task: task, onTap: () => _openTaskDetails(context, task)),
      feedback: SizedBox(
        width: MediaQuery.of(context).size.width * 0.25,
        child: Material(elevation: 4.0, child: TaskCard(task: task)),
      ),
      childWhenDragging: Opacity(opacity: 0.5, child: TaskCard(task: task)),
    );
  }

  void _openTaskDetails(BuildContext context, Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
    );
  }

  void _addTask(BuildContext context, AppStateProvider appState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Déclaration des variables en dehors du StatefulBuilder
        String title = '';
        String description = '';
        Label? selectedLabel;
        DateTime dueDate = DateTime.now();

        // Déclaration des TextEditingControllers
        TextEditingController titleController = TextEditingController(
          text: title,
        );
        TextEditingController descriptionController = TextEditingController(
          text: description,
        );

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: MediaQuery.of(context).size.height * 0.7,
                height: MediaQuery.of(context).size.height * 0.7,
                padding: const EdgeInsets.all(16.0),
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitleField(titleController, 'Title'),
                        const SizedBox(height: 14),
                        _buildTextField(
                          descriptionController,
                          'Description',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Consumer<AppStateProvider>(
                            builder: (context, appState, child) {
                              final labels = appState.labels;
                              return DropdownButton<Label>(
                                value: selectedLabel,
                                hint: const Text(
                                  'Choose a label',
                                  style: TextStyle(color: Colors.black54),
                                ),
                                isExpanded: true,
                                underline: SizedBox(),
                                onChanged: (Label? value) {
                                  setState(() {
                                    selectedLabel = value;
                                  });
                                },
                                items:
                                    labels.map<DropdownMenuItem<Label>>((
                                      Label label,
                                    ) {
                                      return DropdownMenuItem<Label>(
                                        value: label,
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: Color(
                                                label.color,
                                              ),
                                              radius: 6,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(label.name),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton(
                          child: Text(
                            'Due date: ${_formatDateTime(dueDate)}',
                            style: const TextStyle(color: Colors.black),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          onPressed: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: dueDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2026),
                            );
                            if (pickedDate != null) {
                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.fromDateTime(
                                      dueDate,
                                    ),
                                  );
                              if (pickedTime != null) {
                                setState(() {
                                  dueDate = DateTime(
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
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 10,
                      right: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              if (titleController.text.isNotEmpty &&
                                  selectedLabel != null) {
                                final newTask = Task(
                                  title: titleController.text,
                                  description: descriptionController.text,
                                  label: selectedLabel!.name,
                                  dueDate: dueDate,
                                  status: 'To Do',
                                );
                                appState.addTask(newTask);
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTitleField(TextEditingController controller, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 3,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 16),
          maxLength: 80,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
