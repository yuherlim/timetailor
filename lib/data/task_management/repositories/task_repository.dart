import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timetailor/data/task_management/models/task.dart';

class TaskRepository {
  // Firestore collection reference with converters for the Task class
  final ref = FirebaseFirestore.instance.collection("tasks").withConverter<Task>(
        fromFirestore: Task.fromFirestore,
        toFirestore: (Task task, _) => task.toFirestore(),
      );

  // Add a new task
  Future<void> addTask(Task task) async {
    await ref.doc(task.id).set(task);
  }

  // Get all tasks once
  Future<QuerySnapshot<Task>> getTasksOnce() {
    return ref.orderBy("startTime", descending: false).get();
  }

  // Get a task by ID
  Future<Task?> getTaskById(String taskId) async {
    final doc = await ref.doc(taskId).get();
    return doc.data(); // Automatically converted to a Task object
  }

  // Get tasks for a specific user
  Future<List<Task>> getTasksByUserId(String userId) async {
    final querySnapshot = await ref.where("userId", isEqualTo: userId).get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  // Update task details
  Future<void> updateTask(Task task) async {
    await ref.doc(task.id).update({
      "name": task.name,
      "description": task.description,
      "date": Timestamp.fromDate(task.date),
      "startTime": Timestamp.fromDate(task.startTime),
      "duration": task.duration,
      "endTime": Timestamp.fromDate(task.endTime),
      "isCompleted": task.isCompleted,
      "linkedNotes": task.linkedNotes,
      "userId": task.userId,
    });
  }

  // // Mark task as completed
  // Future<void> markTaskAsCompleted(String taskId) async {
  //   await ref.doc(taskId).update({
  //     "isCompleted": true,
  //   });
  // }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    await ref.doc(taskId).delete();
  }
}
