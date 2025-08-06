import 'package:flutter/material.dart';
import 'package:fluttter_test/task_model.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;
  final ValueChanged<bool?> onToggleCompleted;

  const TaskCard({
    super.key,
    required this.task,
    required this.onUpdate,
    required this.onDelete,
    required this.onToggleCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                
                // Title and Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: task.completed ? Colors.grey : Colors.black,
                          decoration: task.completed
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 8.0),
                        Text(
                          task.description,
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),


                // Checkbox
                Checkbox(
                  value: task.completed,
                  onChanged: onToggleCompleted,
                ),
              ],
            ),


            // Action Buttons

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'author: ${task.username}',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 82.0),
                TextButton(onPressed: onUpdate, child: const Text('EDIT')),
                TextButton(
                    onPressed: onDelete,
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('DELETE')),
              ],
            )
          ],
        ),
      ),
    );
  }
}
